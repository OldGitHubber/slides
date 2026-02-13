# Inherit provider from parent so no need to add it explicitly here
# Subnet needs to exist. It is created by the vnet module


# depends_on needed as terraform doesn't seem to know which order to delete these things. Probably dodgy Azure API
# Create security group for the subnet to protect all resources in it
resource "azurerm_network_security_group" "main" {
  depends_on          = [azurerm_network_interface.main] # Make sure there is a NIC to attach this security group to as TF doesn't seem to be able to work it out
  name                = "${var.nsg_name}-nsg"            # Name it and stick an nsg on the end for readability
  location            = var.location                     # Region
  resource_group_name = var.resource_group_name          # Which resource group to deploy into

  security_rule {
    name                       = var.inbound_security_rule.name     # Call it anything you want. It is seen in the console inound ports list
    priority                   = var.inbound_security_rule.priority # Lower numbers have higher priority
    direction                  = "Inbound"
    access                     = "Allow"                              # Allow or Deny trafic
    protocol                   = "Tcp"                                # e.g. tcp, udp or * for all protocols
    source_port_range          = "*"                                  # Allow any source port number. Web clients use random port numbers
    destination_port_ranges    = var.inbound_security_rule.dest_ports # List of ports to oppen. Restrict inbound traffic to target these ports. Source it the cient, dest is the server
    source_address_prefix      = "*"                                  # Don't care who is connecting. Limit by providing address list or range
    destination_address_prefix = "*"                                  # We don't care which IP address we route the traffic to in the network
  }
}


resource "azurerm_network_interface" "main" {
  name                = "${var.nsg_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.ip_config_name                                            # Can be anything that makes sense when viewed in the portal
    subnet_id                     = var.subnet_id                                                 # Connect this NIC to the subnet based on id
    private_ip_address_allocation = var.private_ip.type                                           # Private IP allocated out of subnet pool if dynamic. Provide IP if type is static
    private_ip_address            = var.private_ip.address                                        # Set this to null if using static
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.main-ip[0].id : null # As IP count is set, need index in case there are more than one Pub IP. 0=none
  }

}

# Create a public IP address
resource "azurerm_public_ip" "main-ip" {
  count               = var.assign_public_ip ? 1 : 0 # Boolean. If true, count IPs is 1 else 0
  name                = "${var.publicIP.name}-pubIP"
  location            = var.location             # Which region is resource group as we can span regions
  resource_group_name = var.resource_group_name  # RG name this IP belongs to
  allocation_method   = var.publicIP.type        # Static cost more but stay in place after a restart
  sku                 = var.publicIP.sku         # Ensure SKU is set to Standard for static
  domain_name_label   = var.publicIP.domain_name # This should be unique within the region. Azure will add the .uksouth.cloudapp.azure.com
}

# We need to connect the security group to the network card
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id # Link by IDs
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.vm_spec.name}-VM" # Call it what you want. This is how it will look in the portal
  resource_group_name = var.resource_group_name  # Place in resource group
  location            = var.location
  size                = var.vm_spec.size # Free tier VM size - use B2s or similar if using a database
  admin_username      = var.vm_spec.admin-name

  network_interface_ids = [
    azurerm_network_interface.main.id, # Connect the VM to its NIC. The NIC is already connected to the NSG 
  ]

  os_disk {
    name                 = "${var.vm_spec.name}-osdisk"
    caching              = var.disk_spec.caching-type # Enable caching for performance
    storage_account_type = var.disk_spec.storage-type # Standard locally redundant storage. Uses HDD AWS offers SSD on free tier. Replicates 3 x in data centre
    # Alternatives: StandardSSD_LRS, Premium_LRS, UltraSSD_LRS
    disk_size_gb = var.disk_spec.size-gb
  }

  source_image_reference {
    publisher = var.OS_image.publisher
    offer     = var.OS_image.type    # You need to look these things up
    sku       = var.OS_image.sku     # OS version base image version
    version   = var.OS_image.version # Latest including minor updates or e.g. 2021.04.01 for one released then
  }

  admin_ssh_key {
    username = var.vm_spec.admin-name
    # Just copy public key from Azure ssh keys if you have one
    public_key = file(var.pub_key)
  }


  #Copy docker hub password file to vm to enable login without putting password in code
  provisioner "file" {
    source      = "${var.docker_hub_pass_dir}/${var.docker_hub_pass_filename}"
    destination = "${var.dest_dir}/${var.docker_hub_pass_filename}"
    connection {
      type        = "ssh"
      user        = "tony"
      private_key = file(var.private_key_file)
      host        = self.public_ip_address
    }
  }
}


# Install docker on the created VM. Depends on the VM existing
# Copy the docker-az.sh script to the vm
# Login to the vm and run the script
resource "null_resource" "install_docker" {
  depends_on = [azurerm_linux_virtual_machine.main]

  # Copy docker install script to VM
  provisioner "file" {
    source      = "${var.docker_install_dir}/${var.docker_install_script}"
    destination = "${var.dest_dir}/${var.docker_install_script}"
    connection {
      type        = "ssh"
      user        = "tony"
      private_key = file(var.private_key_file)
      host        = azurerm_linux_virtual_machine.main.public_ip_address
    }
  }

  # Install docker
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${var.dest_dir}/${var.docker_install_script}", # Make the script executable
      "sudo ${var.dest_dir}/${var.docker_install_script}"      # do it
    ]
    connection {
      type        = "ssh"
      user        = "tony"
      private_key = file(var.private_key_file)
      host        = azurerm_linux_virtual_machine.main.public_ip_address
    }
  }
}


# Once the VM is created and docker is installed, copy the compose file to the VM and start the containers
# The trigger enables this resource to run every time as the assumption is that running another apply is likely to be because
# the code has changed and the containers need to be updated
# Copying the compose file even if it hasn't changed is harmless as it will just overwrite the existing file
# By using for, we can add a lost of files files to copy
resource "null_resource" "copy_config_files" {
  depends_on = [azurerm_linux_virtual_machine.main, null_resource.install_docker]
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
      user        = "tony"
      private_key = file(var.private_key_file)
      host        = azurerm_linux_virtual_machine.main.public_ip_address
    }
  }
}


resource "null_resource" "start_containers" {
  depends_on = [azurerm_linux_virtual_machine.main, null_resource.install_docker, null_resource.copy_config_files]
  triggers = {
    always_run = "${timestamp()}" # always_run this null resource. Could check if image changed if you want to add code for that
  }

  # Note: adding docker to user group will generate a warning first time apply is run as docker isn't added until log out and in again 
  # so still using sudo here because it will add it which avoids the remote command line user keep using sudo
  # If apply is executed again, the warning isn't raised as this is effectively a new login
  provisioner "remote-exec" {
    inline = [
      "sudo usermod -aG docker ${azurerm_linux_virtual_machine.main.admin_username}", # Add docker to my user group so I don't have to use sudo. Can't do this in shell script or it hangs as the shell is changed
      "sudo docker compose down",
      "cat ~/${var.docker_hub_pass_filename} | docker login --username ${var.docker_hub_user_name} --password-stdin", # Pipe the password from the file into stdin to keep it sort of secret
      "sudo docker compose -f /home/tony/compose.yaml up -d"
    ]
    connection {
      type        = "ssh"
      user        = "tony"
      private_key = file(var.private_key_file)
      host        = azurerm_linux_virtual_machine.main.public_ip_address
    }
  }
}


# Local_exec to build and push the images
# This resource is run every time apply is used as the assumption is that the code has changed and the images need to be updated
# so build and push the images. You need to manually login to docker hub once on the client or could automate this too
# on the client machine 
resource "null_resource" "build-and-push-images" {
 # count = var.build_and_push_images ? 1 : 0

  triggers = {
    always_run = "${timestamp()}" # always_run this null resource. Could check if image changed if you want to add code for that
  }

  # <<-EOT is heredoc - a bodge for interpreters to use multiline strings. Would have been more useful if it had been standardised but
  # bash uses <<EOT, php uses <<<EOT, terraform uses <<-EOT etc. So the technique is common but the syntax slightly different
  # EOT stands for End of Text but you can use anything
  # Build docker images and push to docker hub
  # If build_and_push_images is false, the list of files is empty else create a resource for each in the list
  for_each = toset(var.push_images) # The scope of this loop is module or resource scope.
  provisioner "local-exec" {
    command     = <<-EOT
      docker compose -f "${var.compose_source_dir}/${var.compose_filename}" build
      docker push ${each.value}
    EOT
    interpreter = ["powershell", "-Command"] # Pass the command to powershell
  }
}

# Output useful info about stuff
# Used herdoc as wanted to output in my order not terraform's i.e. alphabetical
output "vm-info" {
  value = <<EOT

    user       = ${var.vm_spec.admin-name}
    public_ip  = ${length(azurerm_public_ip.main-ip) > 0 ? azurerm_public_ip.main-ip[0].ip_address : "No Public IP allocated"}
    private_ip = ${azurerm_network_interface.main.private_ip_address}
    Ports opened: ${join(", ", var.inbound_security_rule.dest_ports)}
    vm_size    = ${var.vm_spec.size}
    
  EOT
}


