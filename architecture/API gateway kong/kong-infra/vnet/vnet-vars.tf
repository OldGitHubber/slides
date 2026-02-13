variable "subscription" {
  type        = string
  description = "User subscrition ID"
}

variable "resource_group_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vnet" {
  description = "Names the VNet and sets the CIDR block range"
  type = object({
    name = string
    cidr = list(string)
  })
}


variable "subnet1" {
  description = "Names the first subnet and sets the CIDR block range"
  type = object({
    name = string
    cidr = list(string)
  })
}

variable "subnet2" {
  description = "Names the second subnet and sets the CIDR block range"
  type = object({
    name = string
    cidr = list(string)
  })
}


