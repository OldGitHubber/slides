#============================================================================================
#
#  Regional stuff
#
#============================================================================================
subscription = "5645f4b2-db38-4326-b7a6-98d374ebdd9c" # Search portal for subscriptions for this

resource_group_name = "CI-CD-demo"

region = "UK South"



#============================================================================================
#
#  Networking
#
#============================================================================================
vnet = {
  name = "CI-CD-demo"
  cidr = ["10.0.0.0/16"]
}

subnet = {
  name = "CI-CD-demo"
  cidr = ["10.0.2.0/24"]
}

# If we don't want a PIP then either just don't create a resource and don't reference PIP in the NIC
# Or make it conditional as in this case and specify with count whether we want one or not. Could call it enable
publicIP = {
  name    = "CI-CD-demo"
  type    = "Static" # If using dynamic sku needs to be basic
  sku     = "Standard"
}

bastion_ip = "bastion"

NIC_name = "CI-CD-demo" # Network interface card name

private_ip_config = {
  name = "main"
  type = "Static" # Can be dynamic. If so, don't provide an IP
  ip   = "10.0.2.4"
}

nsg_name = "CI-CD-demo"

security_rule = {
  name                 = "app-inbound"
  priority             = "100"
  direction            = "Inbound" # Note these values with capitals are case sensitive
  access               = "Allow"
  protocol             = "Tcp"
  source_port_range    = "*"
  source_address_range = "*"
  dest_port_range      = ["22", "4000-4001"]
  dest_address_range   = "*"
}



#============================================================================================
#
#  Virtual Machine
#
#============================================================================================
vm_spec = {
  name       = "CI-CD-demo"   # Cannot had _ in computer name
  size       = "Standard_B1s" # The free one. Choose B2s for database
  admin-name = "tony"
}

disk_spec = {
  caching-type = "ReadWrite"
  storage-type = "Standard_LRS" # spinning rust - free
}

OS_image = {
  publisher = "Canonical"
  type      = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2" # Stock Keepung Unit is the Family name
  version   = "latest"         # This can be a specific build number such as 202402020
}

#Can add the public key here if you want but maintenance overhead if it changes
#pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3IZCxfdNcY28mUCloHDcLuiuDBLLxFYiIuMmtCGDZgplxN+YpCYfokJLzI2kqshslg831TLxJ++nKDUtU7O7XrWM5Hg8S+3ZiCyUcg37GKR9KhZZsTrNTchzVBniJmeeQ/qY1h7i39zQOvzISvylxoed9NAQcUlqOAuzepBWh46ojyTCFdoFi/uV1sfAnfbHrWw/rTJ4r9pG5jsKexNSOMFQTi33Azmbu05JgAXMkMhBVZiI+H0lOQrfVfH6dqE6a3MaoN29qXPNbBsyXUmtlH+EZo3vQRahiC2s4JsWxwD0S7qno+31V85PQ+O8XJQF58VGMD6kHYRsGTbpZbOFbezsYUF1hMoRQYAQ8BjxNWgKhLgsMokeKa4/bnSPsJ0C1VMJuZ101SQIesiOTGB3QR2B9TloPiTC3fCCw0UXooHDkvMxhwef0rwgpsgThaUyUA87oBZL8dGGbHVphZHjwQ7fn1S03dtfm4FqFWBIjnjo7lReTU91Qy05qZL6XZcU="
admin_ssh = {
  admin_name       = "tony"
  pub_key_file     = "c:/key/az.pub"
  private_key_file = "c:/key/az.pem"
}


#===============================================================
#
#  Docker stuff
#
#===============================================================

push_images = ["oldgitdocker/yin:latest", "oldgitdocker/yang:latest"] # List as many images as you want

# Point ot the Docker installation script of your choice. Note use docker-az-tf-swap for small VM with database
docker_install_script = {
  source_dir = "C:/Users/tonyn/OneDrive - UCLan/CO3404/Demos/all_scripts"
  filename   = "docker-az-tf.sh"
}



#===============================================================
#
#  config files structure
#
#===============================================================

# Provide a list of files to copy to the VM
# main.tf assumes that the compose file, whatever it's calles, is first in the list
# So make sure it is
copy_config = [
  {
    source      = "../compose.yaml"
    destination = "/home/tony/compose.yaml"
  },
  {
    source      = "../.env"
    destination = "/home/tony/.env"
  }
]

dest_dir = "/home/tony" # This is the remote destination dir. Typically /home/user
