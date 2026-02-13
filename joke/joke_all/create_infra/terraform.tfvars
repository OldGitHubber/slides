subscription        = "5645f4b2-db38-4326-b7a6-98d374ebdd9c"
resource_group_name = "junk"
region              = "UK South"

vnet = {
  name = "junk"
  cidr = ["10.0.0.0/16"]
}

subnet = {
  name = "junk"
  cidr = ["10.0.1.0/24"]
}

publicIP = {
  name        = "junk"
  type        = "Static" # If using dynamic sku needs ot be basic
  sku         = "Standard"
  domain_name = "junk" # This should be unique within the region. Azure will add the .uksouth.cloudapp.azure.com
}

NIC_name        = "junk" # Network interface card name
ip_config_name  = "main"
private_ip_type = "Dynamic"

nsg_name = "junk"

# ************* VM Size *****************
vm_spec = {
  name       = "junk"
  size       = "Standard_B2s" # The free one B1s. Choose B2s for database
  admin-name = "tony"
}

#***************************************

disk_spec = {
  caching-type = "ReadWrite"
  storage-type = "Standard_LRS" # spinning rust - free
}

OS_image = {
  publisher  = "Canonical"
  type       = "0001-com-ubuntu-server-focal"
  os-version = "20_04-lts-gen2"
}

pub_key          ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD0U3uCcCsl4ARiqgeKAltLmc1EZrw9r6teD+yR70lKthGQxHvgJJeKDlsCfFOCk8h9z9BFTRw1XJOfG1aj0pRSGCzDLCyeDELKODYdsJ3HAXBQy4lpvOxwPwhKtsn6ZKRT82I1p8yRx1Uf1AJO6xpBKCaM2FLVuqUwK2uWRDoscJ6cVilDCbpXWD1kfgBojdBHt/wN3Mo3rMQ+G7dPXWMic/XMgAdl3flCHur5/UCrISS9Rzu1auD30vRYkzhLYrOTggkDNc+6jPr/OAexMhKuCleUgVNaGOBgTsURqtcjtfoOL/5WypSsw+HvhJJpHzjB+kjQiChSM2AGUVLhwX6JTNvyH2Ew7guDAmsN/KwqXy3XvFF4qk2F/pFl9v5Z2esjt+GCoh/DalrWqjCVT75a/aF9y7ImzHPkqi8ShS4iWg/rDnOUE4UEG2IH9284jeH4qhmrRwcl1JybiePqv+KJiVjGziEmRJ7Ukx/q7ZBCOtZtLkQO2dL6Fa6H9zNCOy0="
private_key_file = "c:/key/az.pem"


#*************** SSL Certificate files - comment out if not using ***************************
# cert = {
#   source = "C:\\Certbot\\live\\tnjoke.duckdns.org\\fullchain.pem" 
#   dest-dir = "/home/tony/certs"
#   name   = "fullchain.pem"                   
# }

# key = {
#   source = "C:\\Certbot\\live\\tnjoke.duckdns.org\\privkey.pem"
#   dest-dir = "/home/tony/certs"
#   name   = "privkey.pem"
# }

#*************************************************************

#****************** PORTS *********************
inbound_ports = ["22", "80", "443", "4000"]
#*********************************************

# Now for the variables for the CI/CD part

home_dir = "/home/tony" # Default remote home dir


docker_hub_pass_filename = "docker_hub_pass.txt" # Need this for the remote exec to login to docker

docker_install_dir    = "D:/oneDriveUclan/OneDrive - University of Lancashire/CO3404/Demos/all_scripts"
docker_install_script = "docker-az-tf.sh"

#************************** Compose and images config *****************************

# Provide a list of config files to copy to the VM. This is just to copy the files in one go. Some
# of the files, if explicitly used in a executioner, need to be specified explicitly as we couldn't
# access from this list as we wouldn't know where any particular file was in the list
copy_config = [
  {
    # Copy password file.
    source      = "c:/key/docker_hub_pass.txt"
    destination = "/home/tony/docker_hub_pass.txt"
  },
  {
    # Copy the compose file
    source      = "D:/oneDriveUclan/OneDrive - University of Lancashire/CO3404/Demos/joke/joke_all/compose.yaml"
    destination = "/home/tony/compose.yaml"
  },
  {
    # Copy the .env file
    source      = "D:/oneDriveUclan/OneDrive - University of Lancashire/CO3404/Demos/joke/joke_all/.env"
    destination = "/home/tony/.env"
  },
  {
    # Copy the .sql file
    source      = "D:/oneDriveUclan/OneDrive - University of Lancashire/CO3404/Demos/joke/joke_all/jokes-exported.sql"
    destination = "/home/tony/jokes-exported.sql"
  },
]

compose_filename = "D:/oneDriveUclan/OneDrive - University of Lancashire/CO3404/Demos/joke/joke_all/compose.yaml" # Stupid PS needs \\ need this explicitly for the local exec to run docker


push_images          = ["oldgitdocker/joke:latest"] # List of images to push
docker_hub_user_name = "oldgitdocker"

# duckDNS domain and api token
domain   = "localhost,tnjoke" # tnjoke.duckdns.org
dns_token = "7ae1e366-84b5-4e96-8044-03c2b97176a7"

#*********************************************************************
