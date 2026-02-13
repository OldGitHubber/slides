# I've put the jump box stuff in here to show you that you can do it and it keeps the files smaller
# and is a bit more modular. You would use modules to make it properly modular to avoid code repetition


#============================================================================================
#
#  Regional stuff
#
#============================================================================================
# There is no need for any if it is going in the same region as other resources as it has 
# already been declared once


#============================================================================================
#
#  jumpbox networking
#
#============================================================================================
# ---------------
# Virtual network 
# ---------------
# No need for one if deploying into the same region. If deploying into 2
# regions you would probably put this in a separate file, create both VNets and peer them

# ----------
# Subnetwork
# ----------
# Wouldn't need this if we were deploying into the same subnet as yinYang
resource "azurerm_subnet" "jumpbox" {
  name                 = var.jumpbox_subnet.name                 # Subnet within the Vnet. 
  resource_group_name  = azurerm_resource_group.yinYang.name  # Which resurce group. Same as yinYang for demo
  virtual_network_name = azurerm_virtual_network.yinYang.name # Link VM subnet to Vnet. Same as yinYang in this demo
  address_prefixes     = var.jumpbox_subnet.cidr                 # Subnet cidr block
}

# ----------------------
# Network Security Group
# ----------------------
# Wouldn't need this if we were deploying into the same subnet as yinYang
resource "azurerm_network_security_group" "jumpbox" {
  name                = var.jumpbox_nsg_name
  location            = azurerm_resource_group.yinYang.location # Same region as yinYang in this case
  resource_group_name = azurerm_resource_group.yinYang.name     # Same resource group

  security_rule {
    name                       = var.jumpbox_security_rule.name           # Anything you want
    priority                   = var.jumpbox_security_rule.priority       # Lower numbers have higher priority
    direction                  = var.jumpbox_security_rule.direction
    access                     = var.jumpbox_security_rule.access               # Allow or Deny trafic
    protocol                   = var.jumpbox_security_rule.protocol             # e.g. tcp, udp or * for all protocols
    source_port_range          = var.jumpbox_security_rule.source_port_range    # Allow any source port number. Web clients use random port numbers * is singular so use range
    destination_port_ranges    = var.jumpbox_security_rule.dest_port_range      # Restrict inbound traffic to target these ports. Source is the cient, dest is the server. NOte range(s)
    source_address_prefix      = var.jumpbox_security_rule.source_address_range # Don't care who is connecting. Limit by providing address list or range
    destination_address_prefix = var.jumpbox_security_rule.dest_address_range   # We don't care which IP address we route the traffic to in the network
  }
}

# ----------------------------------------------------------------------------------
# Link the above subnet to the security group that will protect it and its resources
# ----------------------------------------------------------------------------------
# Wouldn't need this if we were deploying into the same subnet as yinYang
resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = azurerm_subnet.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

# ----------------------
# Network Interface Card
# ----------------------
resource "azurerm_network_interface" "jumpbox" {
  name                = var.jumpbox_nic_name
  location            = azurerm_resource_group.yinYang.location  # Same region as yinYang in this demo
  resource_group_name = azurerm_resource_group.yinYang.name      # Same resource group in this case

  ip_configuration {
    name                          = var.jumpbox_private_ip_config.name
    subnet_id                     = azurerm_subnet.jumpbox.id        # Put Bastion in its own subnet. Would be yinYang otherwise
    private_ip_address_allocation = var.jumpbox_private_ip_config.type
    private_ip_address            = var.jumpbox_private_ip_config.ip
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }
}


# ---------
# Public IP
# ---------
resource "azurerm_public_ip" "jumpbox" {
  name                = var.jumpbox_publicIP.name
  location            = azurerm_resource_group.yinYang.location  # Same region as yinYang
  resource_group_name = azurerm_resource_group.yinYang.name      # Same resource group
  allocation_method   = var.jumpbox_publicIP.type
  sku                 = var.jumpbox_publicIP.sku
}


#============================================================================================
#
#  jump box Virtual Machine
#
#============================================================================================
resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                = var.jumpbox_vm.name
  location            = azurerm_resource_group.yinYang.location
  resource_group_name = azurerm_resource_group.yinYang.name
  size                = var.jumpbox_vm.size

  admin_username = var.jumpbox_vm.admin-name

  network_interface_ids = [
    azurerm_network_interface.jumpbox.id # Connect VM to jumpbox NIC
  ]

  admin_ssh_key {
    username   = var.jumpbox_ssh.admin_name
    public_key = file(var.jumpbox_ssh.pub_key_file)
  }

  os_disk {
    caching              = var.jumpbox_disk.caching-type
    storage_account_type = var.jumpbox_disk.storage-type
  }

  source_image_reference {
    publisher = var.jumpbox_image.publisher
    offer     = var.jumpbox_image.type
    sku       = var.jumpbox_image.sku
    version   = var.jumpbox_image.version
  }
}



