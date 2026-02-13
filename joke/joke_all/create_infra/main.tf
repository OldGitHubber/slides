# More difficult with asure. AWS simply need the region
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
  domain_name_label   = var.publicIP.domain_name             # This should be unique within the region. Azure will add the .uksouth.cloudapp.azure.com
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
# and that's supposed to be its job
resource "azurerm_network_security_group" "demo" {
  depends_on          = [azurerm_network_interface.demo] # Make sure there is a NIC to attach this security group to as TF doesn't seem to be able to work it out
  name                = var.nsg_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = "All_app_inbound_ports" # Anything you want
    priority                   = 1001                    # Lower numbers have higher priority
    direction                  = "Inbound"
    access                     = "Allow"           # Allow or Deny trafic
    protocol                   = "Tcp"             # e.g. tcp, udp or * for all protocols
    source_port_range          = "*"               # Allow any source port number. Web clients use random port numbers
    destination_port_ranges    = var.inbound_ports # Restrict inbound traffic to target these ports. Sourde it the cient, sest is the server
    source_address_prefix      = "*"               # Don't care who is connecting. Limit by providing address list or range
    destination_address_prefix = "*"               # We don't care which IP address we route the traffic to in the network
  }
}

# We need to connect the security group to the network card
resource "azurerm_network_interface_security_group_association" "demo" {
  network_interface_id      = azurerm_network_interface.demo.id # Link by IDs
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
    caching              = var.disk_spec.caching-type # Enable caching for performance
    storage_account_type = var.disk_spec.storage-type # Standard locally redundant storage. Uses HDD AWS offers SSD on free tier. Replicates 3 x in data centre
    # Alternatives: StandardSSD_LRS, Premium_LRS, UltraSSD_LRS
  }

  source_image_reference {
    publisher = var.OS_image.publisher
    offer     = var.OS_image.type       # You need to look these things up
    sku       = var.OS_image.os-version # OS version
    version   = "latest"                # Latest 20.04 including minor version updates
  }

  admin_ssh_key {
    username = "tony"
    # Just copy public key from Azure ssh keys if you have one
    public_key = var.pub_key
  }

  # Copy docker install script to VM
  provisioner "file" {
    source      = "${var.docker_install_dir}/${var.docker_install_script}"
    destination = "${var.home_dir}/${var.docker_install_script}"
    connection {
      type        = "ssh"
      user        = "tony"
      private_key = file(var.private_key_file)
      host        = self.public_ip_address
    }
  }

  # Install docker and register IP address with duckDNS as it will have changed when new VM created
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${var.home_dir}/${var.docker_install_script}", # Make the script executable
      "sudo ${var.home_dir}/${var.docker_install_script}",      # do it
      "curl -k 'https://www.duckdns.org/update?domains=${var.domain}&token=${var.dns_token}&ip='",  # Sent IP to duckDNS. Duck will pull it from the request -k avoids tls cert check
    ]
    connection {
      type        = "ssh"
      user        = "tony"
      private_key = file(var.private_key_file)
      host        = self.public_ip_address
    }
  }
}


# Transfer cert and set dest file and dir permissions
# count is set to execute resource once if there is a cert - i.e. we are using them or 0 if we are not so skips transfer
# Moving from no cert to using certs will require a destroy and rebuild as this will run a max of one time
# Also note that a rebuild will cause the cert binding to fail as it has a different IP. Better to create DNS
resource "null_resource" "cert_transfer" {
  count = var.cert.source != "" ? 1 : 0 # Create one resource once if source exists otherwise don't execute this
  # triggers = {
  #    always_run = "${timestamp()}" # always_run this null resource. Use for testing files are copied
  #  }
  depends_on = [azurerm_linux_virtual_machine.demo-vm]

  # Create dir to hold certs. It shouldn't exist as this only runs once on create of the vm
  provisioner "remote-exec" {
    inline = [
    "mkdir -p ${var.cert.dest-dir}"
    ]
  }

  // Copy the secret key to the server which is used with the cert
  provisioner "file" {
    source = var.key.source
   # destination = "/home/tony/remote-cert/key.pem"
   destination = "${var.key.dest-dir}/${var.key.name}"
    on_failure  = continue # If the file is already there it will be read only so copy will fail
  }

  // Copy the cert
  provisioner "file" {
    source      = var.cert.source
  #  destination = "/home/tony/remote-cert/cert.pem"
  destination = "${var.cert.dest-dir}/${var.cert.name}"
    on_failure  = continue # If the file is already there it will be read only so copy will fail
  }

  # With files transferred, lock them down with appropriate permissions
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 444 ${var.key.dest-dir}/${var.key.name}  || echo 'chmod 444 failed'", # 444 read only
      "sudo chmod 644 ${var.cert.dest-dir}/${var.cert.name} || echo 'cmod 644 failed'", # Owner execute others read only
      "sudo chmod 755 ${var.cert.dest-dir} || echo 'cmod 644 failed'",                  # read, write execute for owner, read exec for other. Need exec to traverse a folder
    ]
  }

  connection {
    type        = "ssh"
    user        = var.vm_spec.admin-name
    private_key = file(var.private_key_file)
    host        = azurerm_linux_virtual_machine.demo-vm.public_ip_address
  }
}




# Once the VM is created and docker is installed, copy the compose file to the VM and start the containers
# The trigger enables this resource to run every time as the assumption is that running another apply is likely to be because
# the code has changed and the containers need to be updated
# Copying the compose file even if it hasn't changed is harmless as it will just overwrite the existing file
# By using for, we can add a lost of files files to copy
resource "null_resource" "copy_config_files" {
  depends_on = [azurerm_linux_virtual_machine.demo-vm]
  triggers = {
    always_run = "${timestamp()}" # always_run this null resource. Could check if image changed if you want to add code for that
  }

  # Note: this doesn't just copy multiple files, it creates multiple resources so if there are any other provisiners in here
  # it replicate them too so keeping this separate forom others
  for_each = { for idx, file in var.copy_config : idx => file }

  provisioner "file" {
    source      = each.value.source
    destination = each.value.destination
    connection {
      type        = "ssh"
      user        = "tony"
      private_key = file(var.private_key_file)
      host        = azurerm_linux_virtual_machine.demo-vm.public_ip_address
    }
  }
}


# Could detect the images have changed but it's unlikely they haven't so just run this every time
resource "null_resource" "start_containers" {
  depends_on = [azurerm_linux_virtual_machine.demo-vm, null_resource.build-and-push-images]

  triggers = {
    always_run = "${timestamp()}" # always_run this null resource. Could check if image changed if you want to add code for that
  }

  # Note: adding docker to user group will generate a warning first time apply is run as docker isn't added until log out and in again 
  # so still using sudo here because it will add it which avoids the remote command line user keep using sudo
  # If apply is executed again, the warning isn't raised as this is effectively a new login
  provisioner "remote-exec" {
    inline = [
      "sudo usermod -aG docker $USER", # Add docker to my user group so I don't have to use sudo. Can't do this in shell script or it hangs as the shell is changed
      "sudo docker compose down",
      "cat ~/${var.docker_hub_pass_filename} | docker login --username ${var.docker_hub_user_name} --password-stdin", # Pipe the password from the file into stdin to keep it sort of secret
      "sudo docker compose -f /home/tony/compose.yaml up -d"
    ]
    connection {
      type        = "ssh"
      user        = "tony"
      private_key = file(var.private_key_file)
      host        = azurerm_linux_virtual_machine.demo-vm.public_ip_address
    }
  }
}

# Local_exec to build and push the images
# This resource is run every time apply is used
# When VM has been created, build and push the images. You need to manually login to docker hub once on the client or could automate this too
# on the client machine rather than keep login in from this script
resource "null_resource" "build-and-push-images" {
  triggers = {
    always_run = "${timestamp()}" # always_run this null resource. Could check if image changed if you want to add code for that
  }

  # <<-EOT is heredoc - a bodge for interpreters to use multiline strings. Would have been more useful if it had been standardised but
  # bash uses <<EOT, php uses <<<EOT, terraform uses <<-EOT etc. So the technique is common but the syntax slightly different
  # EOT stands for End of Text but you can use anything
  # Build docker images and push to docker hub
  for_each = toset(var.push_images) # The scope of this is module or resource scope. 
  provisioner "local-exec" {
    command     = <<-EOT
      docker compose -f "${var.compose_filename}" build --no-cache
      docker push ${each.value}
    EOT
    interpreter = ["powershell", "-Command"] # Pass the command to powershell
  }
}

# Output useful info about stuff
output "vm-info" {
  value = {
    user       = var.vm_spec.admin-name
    vm_size    = var.vm_spec.size
    private_ip = azurerm_network_interface.demo.private_ip_address
    public_ip  = azurerm_public_ip.demo-ip.ip_address
  }
}

output "opened_ports" {
  value = "Ports opened: ${join(", ", var.inbound_ports)}" # Param 1 is format. ,space. Joins all strings
}


