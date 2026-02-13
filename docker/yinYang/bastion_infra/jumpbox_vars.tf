# Variables are declared in here. Each can have a type, description and default value

#============================================================================================
#
#  Regional stuff
#
#============================================================================================
# There is no need for any if it is going in the same region as other resources as it has 
# already been declared once


#============================================================================================
#
#  jumpbox networking
#
#============================================================================================

# No Vnet as using yinYang's

variable "jumpbox_subnet" {
  description = "Names the subnet and sets the CIDR block range"
  type = object({
    name = string
    cidr = list(string)
  })
}

variable "jumpbox_nsg_name" {
  type        = string
  description = "Network security group name"
}

variable "jumpbox_security_rule" {
  type = object({
    name                 = string
    priority             = string
    direction            = string
    access               = string
    protocol             = string
    source_port_range    = string       # Declared as list incase more are added. 
    source_address_range = string       # Note: for lists, the property in main is plural
    dest_port_range      = list(string) # Had i used string fo just "*" it would be singuler
    dest_address_range   = string       # e.g. source_port_range v source_port_ranges
  })
}

variable "jumpbox_nic_name" {
  type = string
}

variable "jumpbox_private_ip_config" {
  type = object({
    name = string
    type = string
    ip   = string
  })
}

variable "jumpbox_publicIP" {
  type = object({
    name                = string
    type                = string   # static or dynamic
    sku                 = string
  })
}

#============================================================================================
#
#  jumpbox Virtual Machine
#
#============================================================================================
variable "jumpbox_vm" {
  type = object({
    name       = string
    size       = string
    admin-name = string
  })
}

variable "jumpbox_disk" {
  type = object({
    caching-type = string
    storage-type = string
  })
}

variable "jumpbox_image" {
  type = object({
    publisher = string
    type      = string
    sku       = string
    version   = string
  })
}


variable "jumpbox_ssh" {
  type = object({
    admin_name       = string
    pub_key_file     = string
    private_key_file = string
  })
}


#===============================================================
#
#  Docker stuff
#
#===============================================================

variable "push_images" {
  type = list(string)
}

variable "docker_install_script" {
  type = object({
    source_dir = string
    filename   = string
  })
}


#===============================================================
#
#  config files structure
#
#===============================================================
# This likely references compose as well but as one of a set of config files to copy
variable "copy_config" {
  description = "List of config files to be copied e.g. compose, .env, kong.yaml."
  type = list(object({
    source      = string
    destination = string
  }))
}

variable "dest_dir" {
  type        = string
  description = "Remote destination dir"
}
