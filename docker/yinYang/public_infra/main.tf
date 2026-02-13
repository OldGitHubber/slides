# You need to login to Docker to be able to push to your repo. You only need to do this once
# 
#============================================================================================
#
#  Regional stuff
#
#============================================================================================
provider "azurerm" {
  subscription_id = var.subscription # subscription_id available from console or: az account show --query id --output tsv
  features {}
}


resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name # RG name seen in the portal
  location = var.region
}


#============================================================================================
#
#  Networking
#
#============================================================================================

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

resource "azurerm_public_ip" "demo_ip" {
  name                = var.publicIP.name
  location            = azurerm_resource_group.demo.location # Which region is resource group as we can span regions
  resource_group_name = azurerm_resource_group.demo.name     # RG name this IP belongs to
  allocation_method   = var.publicIP.type                    # These cost more but stay in place after a restart
  sku                 = var.publicIP.sku                     # Ensure SKU is set to Standard for static
}


resource "azurerm_network_interface" "demo" {
  name                = var.NIC_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = var.private_ip_config.name
    private_ip_address_allocation = var.private_ip_config.type
    private_ip_address            = var.private_ip_config.ip
    subnet_id                     = azurerm_subnet.demo.id # Connect this NIC to the subnet
    public_ip_address_id          = azurerm_public_ip.demo_ip.id # Leave this blank if you don't want a public IP and don't declare a PIP
  }
}


resource "azurerm_network_security_group" "demo" {
 ## depends_on          = [azurerm_network_interface.demo] # Make sure there is a NIC to attach this security group to as TF doesn't seem to be able to work it out
  name                = var.nsg_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = var.security_rule.name     # Anything you want
    priority                   = var.security_rule.priority # Lower numbers have higher priority
    direction                  = var.security_rule.direction
    access                     = var.security_rule.access               # Allow or Deny trafic
    protocol                   = var.security_rule.protocol             # e.g. tcp, udp or * for all protocols
    source_port_range          = var.security_rule.source_port_range    # Allow any source port number. Web clients use random port numbers
    destination_port_ranges    = var.security_rule.dest_port_range      # Restrict inbound traffic to target these ports. Sourde it the cient, sest is the server
    source_address_prefix      = var.security_rule.source_address_range # Don't care who is connecting. Limit by providing address list or range
    destination_address_prefix = var.security_rule.dest_address_range   # We don't care which IP address we route the traffic to in the network
  }
}


# We need to connect the security group to the network card
# resource "azurerm_network_interface_security_group_association" "demo" {
#   network_interface_id      = azurerm_network_interface.demo.id # Link by IDs
#   network_security_group_id = azurerm_network_security_group.demo.id
# }

# OR the subnet to the NSG or both but there is no point in donig both so NIC is commented out
# but left in for syntax should it be preferred
resource "azurerm_subnet_network_security_group_association" "demo" {
  subnet_id                 = azurerm_subnet.demo.id
  network_security_group_id = azurerm_network_security_group.demo.id
}



#============================================================================================
#
#  Virtual Machine
#
#============================================================================================
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
    caching              = var.disk_spec.caching-type # Enable caching for performance
    storage_account_type = var.disk_spec.storage-type # Standard locally redundant storage. Uses HDD AWS offers SSD on free tier. Replicates 3 x in data centre
    # Alternatives: StandardSSD_LRS, Premium_LRS, UltraSSD_LRS
  }

  source_image_reference {
    publisher = var.OS_image.publisher
    offer     = var.OS_image.type # You need to look these things up
    sku       = var.OS_image.sku
    version   = var.OS_image.version
  }

  admin_ssh_key {
    username   = var.admin_ssh.admin_name
    public_key = file(var.admin_ssh.pub_key_file)
  }
}



#============================================================================================
#
#  CI/CD stuff using local and remote executioners within NULL resources
#
#============================================================================================

#===============================================================
#
#  Install Docker
#
#===============================================================
# Install docker on the created VM. Depends on the VM existing
# Copy the docker install script to the vm
# Login to the vm and run the script
resource "null_resource" "install_docker" {
  depends_on = [azurerm_linux_virtual_machine.demo-vm]

  # Copy docker install script to VM
  provisioner "file" {
    source      = "${var.docker_install_script.source_dir}/${var.docker_install_script.filename}"
    destination = "${var.dest_dir}/${var.docker_install_script.filename}"
    connection {
      type        = "ssh"
      user        = var.admin_ssh.admin_name
      private_key = file(var.admin_ssh.private_key_file)
      host        = azurerm_linux_virtual_machine.demo-vm.public_ip_address
    }
  }

  # Install docker
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${var.dest_dir}/${var.docker_install_script.filename}", # Make the script executable
      "sudo ${var.dest_dir}/${var.docker_install_script.filename}"      # do it
    ]
    connection {
      type        = "ssh"
      user        = var.admin_ssh.admin_name
      private_key = file(var.admin_ssh.private_key_file)
      host        = azurerm_linux_virtual_machine.demo-vm.public_ip_address
    }
  }
}



#===============================================================
#
#  Copy config files e.g., compose.yaml, .env 
#
#===============================================================
# Once the VM is created and docker is installed, copy the compose file, .env or whatever to the VM and start the containers
# The files are listed in .tfvars in the copy_config structure
# The trigger enables this resource to run every time as the assumption is that running another apply is likely to be because
# the code has changed which could include compose and .env
# Copying the compose file even if it hasn't changed is harmless as it will just overwrite the existing file
# By using for_each, we can add a list of files files to copy - listed in .tfvars
resource "null_resource" "copy_config_files" {
  depends_on = [azurerm_linux_virtual_machine.demo-vm, null_resource.install_docker] # Need the VM to exist
  triggers = {
    always_run = "${timestamp()}" # always_run this null resource. Could check if image changed if you want to add code for that
  }

  # Note: this doesn't just copy multiple files, it creates multiple resources so if there are any other provisiners in here
  # it replicate them too so keeping this separate from others
  for_each = { for idx, file in var.copy_config : idx => file }

  provisioner "file" {
    source      = each.value.source
    destination = each.value.destination
    connection {
      type        = "ssh"
      user        = var.admin_ssh.admin_name
      private_key = file(var.admin_ssh.private_key_file)
      host        = azurerm_linux_virtual_machine.demo-vm.public_ip_address
    }
  }
}


#===============================================================
#
#  Start the containers 
#
#===============================================================
# Stop and restart the containers likly based on an update of the images
# Could detect the images have changed but it's unlikely they haven't so just run this every time
# Before starting, make sure docker installed, configs copied and images pushed
# We also need to make sure the VM exists but install_docker depends on that so only need to check install_docker
# Now starting to get very imperative and should use a different tool
resource "null_resource" "start_containers" {
  depends_on = [null_resource.install_docker, null_resource.copy_config_files, null_resource.build-and-push-images]

  triggers = {
    always_run = "${timestamp()}" # always_run this null resource. Could check if image changed if you want to add code for that
  }

  # Note: adding docker to user group will generate a warning first time apply it's run as docker isn't added until log out and in again 
  # so still using sudo here because the user isn't in the group until the next login
  # If apply is executed again, the warning isn't raised as this is effectively a new login
  provisioner "remote-exec" {
    inline = [
      "sudo usermod -aG docker $USER", # Add docker to my user group so I don't have to use sudo. Can't do this in shell script or it hangs as the shell is changed
      "sudo docker compose down",
      "sudo docker compose -f ${var.copy_config[0].destination} up -d"
    ]
    connection {
      type        = "ssh"
      user        = var.admin_ssh.admin_name
      private_key = file(var.admin_ssh.private_key_file)
      host        = azurerm_linux_virtual_machine.demo-vm.public_ip_address
    }
  }
}

#===============================================================
#
#  Build and Push the images (login to docker hub)
#
#===============================================================
# Local_exec to build and push the images
# This resource is run every time apply is used as it's assumed the images need rebuiloding and pushing
# When VM has been created, build and push the images. You need to manually login to docker hub once on the client or could automate this too
# on the client machine rather than keep logging in from this script
# List of images is specified in .tfvars push_images structure. It assumes the compose file is first in the list i.e. element [0]
resource "null_resource" "build-and-push-images" {
  triggers = {
    always_run = "${timestamp()}" # always_run this null resource. Could check if image changed if you want to add code for that
  }

  # <<-EOT is heredoc - a bodge for interpreters to use multiline strings. Would have been more useful if it had been standardised but
  # bash uses <<EOT, php uses <<<EOT, terraform uses <<-EOT etc. So the technique is common but the syntax slightly different
  # EOT stands for End of Text but you can use anything
  # Build docker images and push to docker hub
  # Assumes compose file is first in list, i.e., [0] 

  # Build images. This asumes compose fiile is first in the list i.e. [0]
  provisioner "local-exec" {
    command     = <<-EOT
      docker compose -f "${var.copy_config[0].source}" build
    EOT
    interpreter = ["powershell", "-Command"] # Pass the command to powershell
  }

  # Iterate through the image push list in .tfvars.
  # <<-EOT is heredoc - a bodge for interpreters to use multiline strings. Would have been more useful if it had been standardised but
  # bash uses <<EOT, php uses <<<EOT, terraform uses <<-EOT etc. So the technique is common but the syntax slightly different
  # EOT stands for End of Text but you can use anything. e.g. start and end with BODGE
  # Push images in the list to docker hub
  # Assumes compose file is first in list, i.e., [0] 
  for_each = toset(var.push_images) # The scope of this is module or resource scope. 
  provisioner "local-exec" {
    command     = <<-EOT
     
      docker push ${each.value}
    EOT
    interpreter = ["powershell", "-Command"] # Pass the command to powershell
  }
}


#============================================================================================
#
#  Outputs VM config, IP addresses and port numbers
#
#============================================================================================

# Output useful info about stuff
output "vm-info" {
  value = {
    user        = var.vm_spec.admin-name
    vm_size     = var.vm_spec.size
    private_ip  = azurerm_network_interface.demo.private_ip_address
    public_ip   = azurerm_linux_virtual_machine.demo-vm.public_ip_address
  }
}

output "opened_ports" {
  value = "${join(", ", var.security_rule.dest_port_range)}" # Param 1 is format. ,space. Joins all strings
}
