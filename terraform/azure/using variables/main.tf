# More difficult with azure. AWS simply need the region
provider "azurerm" {
  # subscription_id available from console or: az account show --query id --output tsv
  subscription_id = var.subscription
  features {}
}


resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name # RG name seen in the portal
  location = var.region
}


resource "azurerm_virtual_network" "demo" {
  name                = var.vnet.name # Value seen in portal
  address_space       = var.vnet.cidr
  location            = azurerm_resource_group.demo.location # Don't know why it can't work out the location from the RG name
  resource_group_name = azurerm_resource_group.demo.name     # Specify resource group. Important it's same for vms to communicate
}

resource "azurerm_subnet" "demo" {
  name                 = var.subnet.name                   # Subnet within the Vnet. 
  resource_group_name  = azurerm_resource_group.demo.name  # Which resurce group. AWS doesn't use RGs
  virtual_network_name = azurerm_virtual_network.demo.name # Link VM subnet to Vnet. Another Vm needs to be different. e.g. 10.0.3.0/24 or however many IPs you want
  address_prefixes     = var.subnet.cidr
}

resource "azurerm_public_ip" "demo-ip" {
  name                = var.publicIP.name
  location            = azurerm_resource_group.demo.location # Which region is resource group as we can span regions
  resource_group_name = azurerm_resource_group.demo.name     # RG name this IP belongs to
  allocation_method   = var.publicIP.type                    # These cost more but stay in place after a restart
  sku                 = var.publicIP.sku                     # Ensure SKU is set to Standard for static

  # Given change to Microsoft student account you may well not want to do this. If on payg then probably yes
  # lifecycle {
  #   prevent_destroy = true # Use this if you want to maintain your IP but you will still pay for it
  # }
}

resource "azurerm_network_interface" "demo" {
  name                = var.NIC_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = var.ip_config_name     # This can be anything that makes sense when viewed in the portal
    subnet_id                     = azurerm_subnet.demo.id # Connect this NIC to the subnet
    private_ip_address_allocation = var.private_ip_type    # Private IP allocated out of subnet pool
    # private_ip_address_allocation = "Static"
    # private_ip_address            = "10.0.2.4" # If you want to specify a specific IP address
    public_ip_address_id = azurerm_public_ip.demo-ip.id # Leave this blank if you don't want a public IP
  }
}

# depends_on needed as terraform doesn't seem to know which order to delete these things
# and that's supposed to be its job. This seems to be fixed now so commented out to see
resource "azurerm_network_security_group" "demo" {
  #  depends_on          = [azurerm_network_interface.demo] # Make sure there is a NIC to attach this security group to as TF doesn't seem to be able to work it out
  name                = var.nsg_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = var.security_rule.name     # Anything you want
    priority                   = var.security_rule.priority # Lower numbers have higher priority
    direction                  = "Inbound"
    access                     = "Allow"                         # Allow or Deny trafic
    protocol                   = "Tcp"                           # e.g. tcp, udp or * for all protocols
    source_port_range          = "*"                             # Allow any source port number. Web clients use random port numbers
    destination_port_ranges    = var.security_rule.inbound_ports # Restrict inbound traffic to target these ports. Sourde it the cient, sest is the server
    source_address_prefix      = "*"                             # Don't care who is connecting. Limit by providing address list or range
    destination_address_prefix = "*"                             # We don't care which IP address we route the traffic to in the network
  }
}

# We need to connect the security group to the network card with this
# resource "azurerm_network_interface_security_group_association" "demo" {
#   network_interface_id      = azurerm_network_interface.demo.id # Link by IDs to NIC
#   network_security_group_id = azurerm_network_security_group.demo.id
# }

# OR connect it to the subnet, or both. Pointless doing both. View config in portal vnet | topology
resource "azurerm_subnet_network_security_group_association" "demo" {
  subnet_id                 = azurerm_subnet.demo.id # Link NSG to subnet
  network_security_group_id = azurerm_network_security_group.demo.id
}

# We now have the supporting infrastructure defined so define the VM
resource "azurerm_linux_virtual_machine" "demo-vm" {
  name                = var.vm_spec.name                 # Call it what you want. This is how it will look in the portal
  resource_group_name = azurerm_resource_group.demo.name # Place in resource group
  location            = azurerm_resource_group.demo.location
  size                = var.vm_spec.size # Free tier VM size - use B2s or similar if using a database
  admin_username      = var.vm_spec.admin-name

  network_interface_ids = [
    azurerm_network_interface.demo.id, # Connect the VM to its NIC. The NIC is already connected to the NSG 
  ]

  os_disk {
    name                 = var.disk_spec.name
    caching              = var.disk_spec.caching-type # Enable caching for performance
    storage_account_type = var.disk_spec.storage-type # Standard locally redundant storage. Uses HDD AWS offers SSD on free tier. Replicates 3 x in data centre
    # Alternatives: StandardSSD_LRS, Premium_LRS, UltraSSD_LRS
  }

  source_image_reference {
    publisher = var.OS_image.publisher
    offer     = var.OS_image.offer # You need to look these things up. OS version
    sku       = var.OS_image.sku   # OS type
    version   = var.OS_image.version
  }

  admin_ssh_key {
    username = "tony"
    # Just copy public key from Azure ssh keys if you have one
    public_key = var.pub_key
  }
}


# Output useful info about the VM
output "vm-info" {
  value = azurerm_public_ip.demo-ip.ip_address
}



