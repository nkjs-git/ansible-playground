provider "azurerm" {
  features {}
}

# Ref: https://www.devopsschool.com/blog/terraform-example-code-for-create-azure-linux-windows-vm-with-file-remote-exec-local-exec-provisioner/

resource "azurerm_resource_group" "myterraformgroup" {
    name     = var.rg_name
    location = var.rg_location

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = var.vnet_name
    address_space       = var.vnet_addr_space
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = var.snet_name
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes     = var.snet_addr_space
}

# -------------- Ansible Control Node -------------------------

# Create public IPs
resource "azurerm_public_ip" "control-node-ip" {
    name                         = var.public_ip_name
    location                     = azurerm_resource_group.myterraformgroup.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "control-node-nsg" {
    name                = var.security_group_name
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "control-node-nic" {
    name                      = var.control_node_nic
    location                  = azurerm_resource_group.myterraformgroup.location
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.control-node-ip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.control-node-nic.id
    network_security_group_id = azurerm_network_security_group.control-node-nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = azurerm_resource_group.myterraformgroup.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "control-node-vm" {
    name                  = var.control_node_name
    location              = azurerm_resource_group.myterraformgroup.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.control-node-nic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "9_1"
      version   = "latest"
    }

    computer_name  = var.control_node_name
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = file("~/.ssh/id_rsa.pub")
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
	    
	connection {
        host = self.public_ip_address
        user = "azureuser"
        type = "ssh"
        private_key = "${file("~/.ssh/id_rsa")}"
        timeout = "4m"
        agent = false
    }
	
	# provisioner "file" {
    #     source = "example_file.txt"
    #     destination = "/tmp/example_file.txt"
    # }

    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo dnf install ansible-core -y",
            "ansible --version",
            "sudo dnf install python3-pip -y",
            "python3 --version",
            "pip --version"
        ]
    }
	
	# provisioner "local-exec" {
    # command = "deploy.bat"
	# }
}


# -------------- Ansible Managed Node -------------------------

resource "azurerm_public_ip" "managedVMIP01" {
    name                         = var.managed_node_ip01
    location                     = azurerm_resource_group.myterraformgroup.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "managedNodeNIC01" {
    name                      = var.managed_node_ip01
    location                  = azurerm_resource_group.myterraformgroup.location
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "managedNicConfiguration01"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.managedVMIP01.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example-managed01" {
    network_interface_id      = azurerm_network_interface.managedNodeNIC01.id
    network_security_group_id = azurerm_network_security_group.control-node-nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "managedVM01" {
    name                  = var.managed_node_name01
    location              = azurerm_resource_group.myterraformgroup.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.managedNodeNIC01.id]
    size                  = var.managed_node_size01

    os_disk {
        name              = "myOsDisk01"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
    }

    computer_name  = var.managed_node_name01
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = file("~/.ssh/id_rsa.pub")
    }

    # boot_diagnostics {
    #     storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    # }

    tags = {
        environment = "Terraform Demo"
    }
	    
	connection {
        host = self.public_ip_address
        user = "azureuser"
        type = "ssh"
        private_key = "${file("~/.ssh/id_rsa")}"
        timeout = "4m"
        agent = false
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt update -y",
            "sudo apt install python3-pip -y",
            "python3 --version",
            "pip --version"
        ]
    }
}

