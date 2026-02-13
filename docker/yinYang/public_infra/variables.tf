# Variables are declared in here. Each can have a type, description and default value

#============================================================================================
#
#  Regional stuff
#
#============================================================================================
variable "subscription" {
  type        = string
  description = "User subscrition ID"
}


variable "resource_group_name" {
  type    = string
  default = "junk-rg"
}

variable "region" {
  type    = string
  default = "West Europe"
}


#============================================================================================
#
#  Networking
#
#============================================================================================
variable "vnet" {
  description = "Names the VNet and sets the CIDR block range"
  type = object({
    name = string
    cidr = list(string)
  })
  default = {
    name = "junk_vnet"
    cidr = ["10.0.0.0/16"]
  }
}

variable "subnet" {
  description = "Names the subnet and sets the CIDR block range"
  type = object({
    name = string
    cidr = list(string)
  })
}

variable "publicIP" {
  type = object({
    name    = string
    type    = string
    sku     = string
  })
}

variable "NIC_name" {
  type = string
}

variable "private_ip_config" {
  type = object({
    name = string
    type = string
    ip   = string
  })
}



variable "nsg_name" {
  type        = string
  description = "Network security group name"
}

variable "security_rule" {
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

variable "bastion_ip" {
  type = string
}

#============================================================================================
#
#  Virtual Machine
#
#============================================================================================
variable "vm_spec" {
  type = object({
    name       = string
    size       = string
    admin-name = string
  })
}

variable "disk_spec" {
  type = object({
    caching-type = string
    storage-type = string
  })
}

variable "OS_image" {
  type = object({
    publisher = string
    type      = string
    sku       = string
    version   = string
  })
}


variable "admin_ssh" {
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
