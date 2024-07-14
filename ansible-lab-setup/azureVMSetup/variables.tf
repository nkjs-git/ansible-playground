variable "rg_name" {
    type = string
    default = "ansible-playground"
}

variable "rg_location" {
    type = string
    default = "eastus"
}

variable "vnet_name" {
    type = string
    default = "ansbile-playground-vnet"
}

variable "vnet_addr_space" {
    type = list(string)
    default = ["10.0.0.0/16"]
}

variable "snet_name" {
    type = string
    default = "ansbile-playground-snet01"
}

variable "snet_addr_space" {
    type = list(string)
    default = ["10.0.0.0/24"]
}

variable "public_ip_name" {
    type = string
    default = "control-node-ip"
}

variable "security_group_name" {
    type = string
    default = "control-node-sg"
}

variable "control_node_nic" {
    type = string
    default = "control_node_nic"
}

variable "control_node_name" {
    type = string
    default = "control-node"
}

variable "control_node_size" {
    type = string
    default = "Standard_DS1_v2"
}

variable "managed_node_nic01" {
    type = string
    default = "managed_node_nic01"
}

variable "managed_node_ip01" {
    type = string
    default = "managed_node_ip01"
}

variable "managed_node_name01" {
    type = string
    default = "managed-node"
}

variable "managed_node_size01" {
    type = string
    default = "Standard_DS2_v2"
}

variable "vm_admin_username" {
    type = string
    default = "azureuser"
}

variable "vm_admin_password" {
    type = string
    default = "Password1234!"
}