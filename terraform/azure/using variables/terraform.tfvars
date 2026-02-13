subscription        = "5645f4b2-db38-4326-b7a6-98d374ebdd9c"
resource_group_name = "junky"
# region = "leave blank to show default use"
vnet = {
  name = "junk"
  cidr = ["10.0.0.0/16"]
}

subnet = {
  name = "junk"
  cidr = ["10.0.2.0/24"]
}

publicIP = {
  name = "junk"
  type = "Static" # If using dynamic sku needs to be basic
  sku  = "Standard"
}

NIC_name = "junk" # Network interface card name
# ip_config_name = "using default"
# private_ip_type = "using default"

nsg_name = "junk"


security_rule = {
  name          = "All_inbound_ports"
  priority      = 1000 # Rule number
  inbound_ports = ["22", "4000-4001"]
}

vm_spec = {
  name       = "junk"
  size       = "Standard_B1s" # The free one NOT ANYMORE. Choose B2s for database
  admin-name = "tony"
}

disk_spec = {
  name         = "junk-disk"
  caching-type = "ReadWrite"
  storage-type = "Standard_LRS" # spinning rust - free NO LONGER BUT CHEAPER. This is being depreciated going forward
}

OS_image = {
  publisher = "Canonical"
  offer     = "ubuntu-24_04-lts"
  sku       = "server"
  version   = "latest"
}

pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD0U3uCcCsl4ARiqgeKAltLmc1EZrw9r6teD+yR70lKthGQxHvgJJeKDlsCfFOCk8h9z9BFTRw1XJOfG1aj0pRSGCzDLCyeDELKODYdsJ3HAXBQy4lpvOxwPwhKtsn6ZKRT82I1p8yRx1Uf1AJO6xpBKCaM2FLVuqUwK2uWRDoscJ6cVilDCbpXWD1kfgBojdBHt/wN3Mo3rMQ+G7dPXWMic/XMgAdl3flCHur5/UCrISS9Rzu1auD30vRYkzhLYrOTggkDNc+6jPr/OAexMhKuCleUgVNaGOBgTsURqtcjtfoOL/5WypSsw+HvhJJpHzjB+kjQiChSM2AGUVLhwX6JTNvyH2Ew7guDAmsN/KwqXy3XvFF4qk2F/pFl9v5Z2esjt+GCoh/DalrWqjCVT75a/aF9y7ImzHPkqi8ShS4iWg/rDnOUE4UEG2IH9284jeH4qhmrRwcl1JybiePqv+KJiVjGziEmRJ7Ukx/q7ZBCOtZtLkQO2dL6Fa6H9zNCOy0= generated-by-azure"