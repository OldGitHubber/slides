# More difficult with azure. AWS simply need the region
provider "azurerm" {
  # subscription_id available from console (search subscriptions) or: az account show --query id --output tsv
  subscription_id = "5645f4b2-db38-4326-b7a6-98d374ebdd9c"
  features {} # Needed even is not using - e.g. prevent deletion rules
}


resource "azurerm_resource_group" "demo" {
  name     = "demo-minimal-rg" # RG name seen in the portal
  location = "UK South"
}


resource "azurerm_virtual_network" "demo" {
  name                = "demo-vnet"     # Value seen in portal
  address_space       = ["10.0.0.0/16"] # Could use /8 but /16 is far more than needed anyway. /16 gives us 2^16 IP addresses
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name # Specify resource group. Important it's common for vms to communicate
}

resource "azurerm_subnet" "demo" {
  name                 = "demo-subnet"                     # Subnet within the Vnet. 
  resource_group_name  = azurerm_resource_group.demo.name  # Which resource group. AWS doesn't use RGs
  virtual_network_name = azurerm_virtual_network.demo.name # Link VM subnet to Vnet. Another Vm needs to be different. e.g. 10.0.2.0/24 or however many IPs you want
  address_prefixes     = ["10.0.1.0/24"]                   # /24 gives us 2^8 or 256 IPs. Minus 3 used by Azure and - another for broadcast
}

resource "azurerm_public_ip" "demo-ip" {
  name                = "demo-pip"
  location            = azurerm_resource_group.demo.location # Which region is resource group as we can span regions
  resource_group_name = azurerm_resource_group.demo.name     # RG name this IP belongs to
  #allocation_method   = "Dynamic"   # Dynamic is about $0.004/hour and static is $0.005/hour. New every restart
  allocation_method = "Static"   # These cost more but stay in place after a restart but not a rebuild if deleted
  sku               = "Standard" # Ensure SKU is set to Standard for static

  # Given change to Microsoft student account you may well not want to do this
  # lifecycle {
  #   prevent_destroy = true # Use this if you want to maintain your IP but you will still pay for it
  # }

}

resource "azurerm_network_interface" "demo" {
  name                = "demo-nic"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "internal"             # This can be anything that makes sense when viewed in the portal
    subnet_id                     = azurerm_subnet.demo.id # Connect this NIC to the subnet
    private_ip_address_allocation = "Dynamic"              # Private IP allocated out of subnet pool
    # private_ip_address_allocation = "Static"
    # private_ip_address            = "10.0.2.4" # If you want to specify a specific IP address
    public_ip_address_id = azurerm_public_ip.demo-ip.id # Leave this blank if you don't want a public IP
  }
}

# depends_on needed as terraform doesn't seem to know which order to delete these things
# and that's supposed to be its job
resource "azurerm_network_security_group" "demo" {
  # depends_on          = [azurerm_network_interface.demo] # Make sure there is a NIC to attach this security group to as TF doesn't seem to be able to work it out
  name                = "demo-nsg"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = "All_app_inbound_ports" # Anything you want
    priority                   = 1000                    # Lower numbers have higher priority
    direction                  = "Inbound"
    access                     = "Allow"                          # Allow or Deny traffic
    protocol                   = "Tcp"                            # e.g. tcp, udp or * for all protocols
    source_port_range          = "*"                              # Allow any source port number. Web clients use random port numbers
    destination_port_ranges    = ["22", "4000-4001", "5000-5004"] # Restrict inbound traffic to target these ports. Source it the client, dest is the server
    source_address_prefix      = "*"                              # Don't care who is connecting. Limit by providing address list or range
    destination_address_prefix = "*"                              # We don't care which IP address we route the traffic to in the network
  }
}

# We need to connect the security group to the network card with this
# resource "azurerm_network_interface_security_group_association" "demo" {
#   network_interface_id      = azurerm_network_interface.demo.id # Link by IDs to NIC
#   network_security_group_id = azurerm_network_security_group.demo.id
# }

# OR connect it to the subnet, or both. Pointless doing both - done here for demo). View config in portal vnet | topology
resource "azurerm_subnet_network_security_group_association" "demo" {
  subnet_id                 = azurerm_subnet.demo.id # Link NSG to subnet
  network_security_group_id = azurerm_network_security_group.demo.id
}

# We now have the supporting infrastructure defined so define the VM
resource "azurerm_linux_virtual_machine" "demo-vm" {
  name                = "demo-vm1"                       # Call it what you want. This is how it will look in the portal
  resource_group_name = azurerm_resource_group.demo.name # Place in resource group
  location            = azurerm_resource_group.demo.location
  size                = "Standard_B1s" # Free tier VM size - use B2s or similar if using a database
  admin_username      = "tony"

  network_interface_ids = [
    azurerm_network_interface.demo.id, # Connect the VM to its NIC. The NIC is already connected to the NSG 
  ]

  os_disk {
    name                 = "demo-disk"
    caching              = "ReadWrite"    # Enable caching for performance
    storage_account_type = "Standard_LRS" # Standard locally redundant storage. Uses HDD AWS offers SSD on free tier. Replicates 3 x in data centre
    # Alternatives: Standard SSD_LRS, Premium_LRS, UltraSSD_LRS
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts" # You need to look these things up
    sku       = "server"           # OS version
    version   = "latest"           # Long Term Support 22.04 including minor version updates
  }

  admin_ssh_key {
    username = "tony"
    # Just copy public key from Azure ssh keys if you have one
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD0U3uCcCsl4ARiqgeKAltLmc1EZrw9r6teD+yR70lKthGQxHvgJJeKDlsCfFOCk8h9z9BFTRw1XJOfG1aj0pRSGCzDLCyeDELKODYdsJ3HAXBQy4lpvOxwPwhKtsn6ZKRT82I1p8yRx1Uf1AJO6xpBKCaM2FLVuqUwK2uWRDoscJ6cVilDCbpXWD1kfgBojdBHt/wN3Mo3rMQ+G7dPXWMic/XMgAdl3flCHur5/UCrISS9Rzu1auD30vRYkzhLYrOTggkDNc+6jPr/OAexMhKuCleUgVNaGOBgTsURqtcjtfoOL/5WypSsw+HvhJJpHzjB+kjQiChSM2AGUVLhwX6JTNvyH2Ew7guDAmsN/KwqXy3XvFF4qk2F/pFl9v5Z2esjt+GCoh/DalrWqjCVT75a/aF9y7ImzHPkqi8ShS4iWg/rDnOUE4UEG2IH9284jeH4qhmrRwcl1JybiePqv+KJiVjGziEmRJ7Ukx/q7ZBCOtZtLkQO2dL6Fa6H9zNCOy0= generated-by-azure"
  }
}


# Output VM public IP
output "PublicIP" {
  value = azurerm_public_ip.demo-ip.ip_address
}



