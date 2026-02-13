provider "azurerm" {
  features {}
  subscription_id = var.subscription
}

# Reference the remote state of the network
data "terraform_remote_state" "vnet-state" {
  backend = "local"
  config = {
    path = "../vnet/terraform.tfstate"
  }
}


module "consumer_vm" {
  source                = "../modules/vm"
  location              = data.terraform_remote_state.vnet-state.outputs.resource_group_location
  assign_public_ip      = var.assign_public_ip
  publicIP              = var.publicIP # Send whole object
  nsg_name              = var.nsg_name
  inbound_security_rule = var.inbound_security_rule # List of ports to open in VM NSG
  resource_group_name   = data.terraform_remote_state.vnet-state.outputs.resource_group_name
  ip_config_name        = var.ip_config_name
  private_ip            = var.private_ip
  vm_spec               = var.vm_spec
  disk_spec             = var.disk_spec
  OS_image              = var.OS_image
  pub_key               = var.pub_key
  subnet_id             = data.terraform_remote_state.vnet-state.outputs.subnet1_id
  vnet_name             = data.terraform_remote_state.vnet-state.outputs.vnet_name

  compose_source_dir       = var.compose_source_dir
  compose_filename         = var.compose_filename
  dest_dir                 = var.dest_dir
  private_key_file         = var.private_key_file
  docker_hub_pass_dir      = var.docker_hub_pass_dir
  docker_hub_pass_filename = var.docker_hub_pass_filename
  docker_install_dir       = var.docker_install_dir
  docker_install_script    = var.docker_install_script
  docker_hub_user_name     = var.docker_hub_user_name
  push_images              = var.push_images
}


output "vm-details" {
  value = module.consumer_vm.vm-info
}
