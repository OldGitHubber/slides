# Variables are declared in here. Each can have a type, description and default value
variable "subscription" {
  type        = string
  description = "User subscription ID"
}


variable "resource_group_name" {
  type    = string
  default = "junk-rg"
}

variable "region" {
  type    = string
  default = "West Europe"
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
    name        = string
    type        = string
    sku         = string
    domain_name = string
  })
}

variable "NIC_name" {
  type = string
}

variable "ip_config_name" {
  type        = string
  description = "Can be anything that makes sense"
}

variable "private_ip_type" {
  type        = string
  description = "Dynamic or static. If static, needs IP address"
}

variable "nsg_name" {
  type        = string
  description = "Network security group name"
}

variable "inbound_ports" {
  type = list(string)
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
  })
}

variable "OS_image" {
  type = object({
    publisher  = string
    type       = string
    os-version = string
  })
}

variable "pub_key" {
  type = string
}

variable "cert" {
  type = object({
    source   = string
    dest-dir = string
    name     = string
  })
  default = {
    source   = ""
    dest-dir = ""
    name     = ""
  }
}

variable "key" {
  type = object({
    source   = string
    dest-dir = string
    name     = string
  })
  default = {
    source   = ""
    dest-dir = ""
    name     = ""
  }
}


# Now for the variables for the CI/CD part

variable "compose_filename" {
  type        = string
  description = "Separate to the dir in case we want to use something other than Compose.yaml"
}

# This likely references compose as well but as one of a set of config files to copy
variable "copy_config" {
  description = "List of config files to be copied e.g. compose, .env, kong.yaml."
  type = list(object({
    source      = string
    destination = string
  }))
}

variable "home_dir" {
  type        = string
  description = "Destination dir for build files"
}

variable "private_key_file" {
  type = string
}


# Need this for the remote exec as it needs the filename and as it is copied in a list
# we can't guarantee where in the list it will be so need to specify explicitly
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

# duckDNS names
variable "domain" {
  type = string
}

# duckDNS token
variable "dns_token" {
  type = string
}
