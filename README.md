# Ansbile Playground on Azure

Using this project you will be able to create ansible playgound on Azure using terraform and later you can try different ansible playbooks and role as specfied in this repo

## Create the playground infra

The 'ansible-lab-setup/azureVMSetup' folder consists of terraform config file which will create 2 VMs with below configs
 1. "RedHat 9.1" which will be acting as ansible control node with ansible pre-installed on it
 2. "Ubuntu 22.04" which will be acting as ansible managed node with python and pip installed

Go through the terraform and update the configs according to your choice and run below commands to create infra on VM

  #### terraform init -> To install required plugins 
  #### terraform plan -> To verify the resources which will be created
  #### terraform apply -> To create resource on azure

Post apply the resources will be created in your azure subscription.

## Enable passwordless authentication between control node and managed node.

To enabled the passwordless authentication between two node created, login to control node (i.e. RedHat node) and run below steps:

  1. Generate ssh keys using "ssh-keygen" command to generate new ssh keys for authenticating managed nodes
  2. Copy the public ssh key into managed node using command "ssh-copy-id <managed-node-username>@<manaed-node-ip>". This will ask for password for one last time.
  3. Add managed node IP into ansible inventory host list by editing the hosts file at path "sudo vi /etc/ansible/hosts" and add a entry of managed node into the file either as a group or individual host.

## Test ansible playground

To test the ansible playground created lets run below command to ping all the hosts in the playground.

  #### ansible all -m ping

You should see a pong response from the managed host that has been added in inventory file.

## Run the playbooks

Feel free to explore and run different playbooks available under ./playbooks folder and also go through the common commands used for playbook running mentioned in file ./playbooks/importantCommands.txt

## Explore Ansible adhoc commands

You can try few adhoc commands mentioned in file under adhoc-commands folder

## Try ansible role

Go through the roles available under ansibleRoles which are basically created to install nginx and to update firewall for it.


##### Happy learning!!!!

