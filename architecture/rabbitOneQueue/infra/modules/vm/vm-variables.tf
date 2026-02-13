variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "pub_key" {
  type = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP address to the network interface"
  type        = bool
  default     = false
}

variable "publicIP" {
  type = object({
    name = string
    type = string
    sku  = string
  })
}

variable "inbound_security_rule" {
  type = object({
    name       = string
    priority   = number
    dest_ports = list(string)
  })
}

variable "nsg_name" {
  type        = string
  description = "Network security group name"
}

variable "ip_config_name" {
  type        = string
  default     = "main"
  description = "Can be anything that makes sense"
}

variable "private_ip" {
  type = object({
    type    = string # Static or Dynamic
    address = string # Null if dynamic or an IP if static
  })

  default = {
    type    = "Dynamic"
    address = null
  }
  description = <<-EOT
    Dynamic or static. If static, needs an IP address:
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.2.4" # If you want to specify a specific IP address"
  EOT
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
    caching-type = string
    storage-type = string
    size-gb      = string
  })
}

variable "OS_image" {
  type = object({
    publisher = string
    type      = string
    sku       = string # Stock Keeping Unit - base version. e.g. 20.04-LTS Long Term Support
    version   = string # Latest - includes minor updates. Could use 2021.04.01 for specific image release date
  })
}


variable "subnet_id" {
  type        = string
  description = "Subnet id"
}

variable "vnet_name" {
  type        = string
  description = "Virtual network id"
}


# Now for the variables for the CI/CD part
variable "compose_source_dir" {
  type        = string
  description = "Source dir of the docker compose file to copy to dest"
}

variable "compose_filename" {
  type        = string
  description = "Separate to the dir in case we want to use something other than Compose.yaml"
}

variable "dest_dir" {
  type        = string
  description = "Destination dir for build files"
}

variable "private_key_file" {
  type = string
}

variable "docker_hub_pass_dir" {
  type = string
}

variable "docker_hub_pass_filename" {
  type = string
}

variable "docker_install_dir" {
  type = string
}

variable "docker_install_script" {
  type = string
}

variable "docker_hub_user_name" {
  type = string
}

variable "push_images" {
  type = list(string)
}









