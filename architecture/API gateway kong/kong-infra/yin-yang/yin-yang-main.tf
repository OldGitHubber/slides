provider "azurerm" {
  features {}
  subscription_id = var.subscription
}

# Reference the remote state of the network. We need details of the vnet to deploy into
# As it is created independantly it has its own state file so we acn interrogate the
# state file to get the details we need. Just point to the state file
data "terraform_remote_state" "vnet-state" {
  backend = "local"
  config = {
    path = "../vnet/terraform.tfstate"
  }
}


# Using a module to create the vm so just need to pass args to it to create what we want
# Actual values are in the .tfvars file so edit that not this one
# Note, this module places each vm in a different subnet. If that's not what you want then you need to change it
module "create_vm" {
  source                = "../modules"                                                        # Point to the vm module to "call" / "include"
  location              = data.terraform_remote_state.vnet-state.outputs.resource_group_location # Get region to deploy into from state
  assign_public_ip      = var.assign_public_ip
  publicIP              = var.publicIP # Send whole object as there are various settings for the public IP
  nsg_name              = var.nsg_name # nsg name of subnet protection
  inbound_security_rule = var.inbound_security_rule
  resource_group_name   = data.terraform_remote_state.vnet-state.outputs.resource_group_name # Get resource group to deploy vm into from state
  ip_config_name        = var.ip_config_name                                                 # Private IP settings
  private_ip            = var.private_ip                                                     # e.g. static, dynamic and address if static
  vm_spec               = var.vm_spec                                                        # Vm type, size etc
  disk_spec             = var.disk_spec                                                      # Type and size of disk
  OS_image              = var.OS_image                                                       # Which os and version to use
  pub_key               = var.pub_key                                                        # Public key needed to allow auto login to the vm
  subnet_id             = data.terraform_remote_state.vnet-state.outputs.subnet2_id          # subnet details to deploy vm into
  vnet_name             = data.terraform_remote_state.vnet-state.outputs.vnet_name           # Get vnet name to deploy vm into, get from state

  # Set up filenames and directories to enable the psudo CI/CD as the provisioners have been put into the vm module as 
  # I want similar things to happen to each vm so just need to pass this info across to the module
  compose_source_dir       = var.compose_source_dir
  compose_filename         = var.compose_filename
  dest_dir                 = var.dest_dir
  copy_config              = var.copy_config
  private_key_file         = var.private_key_file
  docker_hub_pass_dir      = var.docker_hub_pass_dir
  docker_hub_pass_filename = var.docker_hub_pass_filename
  docker_install_dir       = var.docker_install_dir
  docker_install_script    = var.docker_install_script
  docker_hub_user_name     = var.docker_hub_user_name
  push_images              = var.push_images
}


# Values returned from the vm module listing vm details such as public IP allocated
output "vm-details" {
  value = module.create_vm.vm-info
}
