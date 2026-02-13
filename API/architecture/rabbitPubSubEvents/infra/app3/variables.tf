# Variables used to pass values into the module
# They are self explanatory and where not so,
# they have descriptions

variable "subscription" {
  type        = string
  description = "User subscription ID"
}

variable "vm_spec" {
  type = object({
    name       = string
    size       = string
    admin-name = string
  })
  description = "vm name, size, e.g.. B1s, user name"
}

variable "pub_key" {
  type        = string
  description = <<EOF
    You can generate your own keys and add the public key here in raw or point to a file
    Or use the one created in Azure. It keeps a copy of the public key that you can ask for
    the ssh public key is copied to ~/.ssh/authorized_keys on the vm for use in ssh
  EOF
}


variable "disk_spec" {
  type = object({
    caching-type = string
    storage-type = string
    size-gb      = string
  })
  description = "Type, e.g. hdd, ssd, and size"
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
    sku  = string # Standard, basic
    domain_name = string  # e.g. yinyang. Azure adds the region and cloudapp.azure.com
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

variable "OS_image" {
  type = object({
    publisher = string
    type      = string
    sku       = string # Stock Keeping Unit - base version. e.g. 20.04-LTS Long Term Support
    version   = string # Latest - includes minor updates. Could use 2021.04.01 for specific image release date
  })
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

# This likely references compose as well but as one of a set of config files to copy
variable "copy_config" {
  description = "List of config files to be copied e.g. compose, .env, kong.yaml."
  type        = list(object({
    source      = string
    destination = string
  }))
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

variable "docker_install_file" {
  type = object({
    base_dir  = string # could be as simple as c: but with onedrive it will be a dir
    file_dir  = string # will be concatenated to base
    file_name = string # concatenated to both
  })
}

variable "docker_hub_user_name" {
  type = string
}

variable "push_images" {
  type = list(string)
}
