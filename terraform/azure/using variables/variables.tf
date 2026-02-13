# Variables are declared in here. Each can have a type, description and default value
# Several default values used here for demo but increases maintenance and risk as a missing tfvar
# may create a default which over time has changed so both file need to be reviewed. There are
# some values that don't change in say reusable modules so defaults may be useful there

variable "subscription" {
  type        = string
  description = "User subscription ID"
}

variable "resource_group_name" {
  type    = string
  default = "test"
}

variable "region" {
  type    = string
  default = "UK South"
}

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
    name = string
    type = string
    sku  = string
  })
}

variable "NIC_name" {
  type = string
}

variable "ip_config_name" {
  type        = string
  default     = "main"
  description = "Can be anything that makes sense"
}

variable "private_ip_type" {
  type        = string
  default     = "Dynamic"
  description = "Dynamic or static. If static, needs IP address"
}

variable "nsg_name" {
  type        = string
  description = "Network security group name"
}


variable "security_rule" {
  type = object({
    name          = string
    priority      = number
    inbound_ports = list(string)
  })
}

variable "vm_spec" {
  type = object({
    name       = string
    size       = string
    admin-name = string
  })
}

variable "disk_spec" {
  type = object({
    name         = string
    caching-type = string
    storage-type = string
  })
}

variable "OS_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "pub_key" {
  type = string
}
