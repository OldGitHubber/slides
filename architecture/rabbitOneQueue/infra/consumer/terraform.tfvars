
subscription = "5645f4b2-db38-4326-b7a6-98d374ebdd9c" # ** Change

assign_public_ip = true # Public IP? Yes or no

publicIP = {
  name = "consumer" # ** change
  type = "Static"   # If using dynamic, sku needs to be basic
  sku  = "Standard"
}

nsg_name = "consumer" # ** Change

inbound_security_rule = {
  name       = "all-app-ports"
  priority   = 1000
  dest_ports = ["22", "4001"]
}

ip_config_name = "consumer" # ** Change

# Type can be Static or Dynamic. If Static, need an IP. If Dynamic, address=null
private_ip = {
  type    = "Dynamic" # ** Check
  address = null      # ** Check
}

vm_spec = {
  name       = "consumer"     # ** Change
  size       = "Standard_B1s" # ** Check The free one is Standard_B1s. Choose B2s for database
  admin-name = "tony"         # ** Change
}

# Ubuntu 20 min 25GB. 10 GB for mysql if using it. 1-2 GB for node containers. RabitMQ about 20GB + 20%
disk_spec = {
  caching-type = "ReadWrite"
  storage-type = "Standard_LRS" # spinning rust - free
  size-gb      = "30"           # ** Check
}

OS_image = {
  publisher = "Canonical"
  type      = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
  version   = "latest" # e.g., Latest 20.04 including minor version updates
}

# ** Change
#pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD0U3uCcCsl4ARiqgeKAltLmc1EZrw9r6teD+yR70lKthGQxHvgJJeKDlsCfFOCk8h9z9BFTRw1XJOfG1aj0pRSGCzDLCyeDELKODYdsJ3HAXBQy4lpvOxwPwhKtsn6ZKRT82I1p8yRx1Uf1AJO6xpBKCaM2FLVuqUwK2uWRDoscJ6cVilDCbpXWD1kfgBojdBHt/wN3Mo3rMQ+G7dPXWMic/XMgAdl3flCHur5/UCrISS9Rzu1auD30vRYkzhLYrOTggkDNc+6jPr/OAexMhKuCleUgVNaGOBgTsURqtcjtfoOL/5WypSsw+HvhJJpHzjB+kjQiChSM2AGUVLhwX6JTNvyH2Ew7guDAmsN/KwqXy3XvFF4qk2F/pFl9v5Z2esjt+GCoh/DalrWqjCVT75a/aF9y7ImzHPkqi8ShS4iWg/rDnOUE4UEG2IH9284jeH4qhmrRwcl1JybiePqv+KJiVjGziEmRJ7Ukx/q7ZBCOtZtLkQO2dL6Fa6H9zNCOy0="
pub_key = "c:/key/az.pub"

# Now for the variables for the CI/CD part
# ** Check and maybe change all these
compose_source_dir       = "../../consumer" # Dir of compose file
compose_filename         = "compose.yaml"                                                                      # Probably don't need to change
docker_hub_pass_dir      = "c:/key"                                                                            # Dir holding the file with my docker password
docker_hub_pass_filename = "docker_hub_pass.txt"                                                               # File holding my Docker password
docker_hub_user_name     = "oldgitdocker"                                                                      # Github user name
docker_install_dir       = "D:/oneDriveUclan/OneDrive - University of Lancashire/CO3404/Demos/all_scripts"                          # Dir holding docker install script
docker_install_script    = "docker-az-tf.sh"                                                                      # Filename of Docker install script
dest_dir                 = "/home/tony"                                                                        # Dest dir for scripts and .yaml
private_key_file         = "c:\\key\\az.pem"                                                                   # My private key file
push_images              = ["oldgitdocker/consumer:latest"]                                                    # List of images to push to Docker hub
