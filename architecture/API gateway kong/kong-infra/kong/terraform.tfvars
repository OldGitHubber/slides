
subscription = "5645f4b2-db38-4326-b7a6-98d374ebdd9c" # ** Change

state_path = "../vnet/terraform.tfstate" # ** check

assign_public_ip = true # Public IP? Yes or no

publicIP = {
  name = "kong"   # ** change
  type = "Static" # If using dynamic, sku needs to be basic
  sku  = "Standard"
  domain_name = "tnkong" # azure will create tnkong.region.cloudapp.azure.com. e.g. tnkong.uksouth.cloudapp.azure.com
}

nsg_name = "kong" # ** Change

inbound_security_rule = {
  name       = "all-app-ports"
  priority   = 1000
  dest_ports = ["22", "80", "443"]
}

ip_config_name = "kong" # ** Change

# Type can be Static or Dynamic. If Static, need an IP. If Dynamic, address=null
private_ip = {
  type    = "Dynamic" # ** Check
  address = null      # ** Check
}

vm_spec = {
  name       = "kong"         # ** Change
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
pub_key = "c:/key/az.pub"

# Now for the variables for the CI/CD part
# ** Check and maybe change all these
compose_source_dir = "../../kong"    # Dir of compose file
compose_filename   = "compose.yaml"  # Probably don't need to change

# Provide a list of files to copy to the VM
copy_config = [
  {
    source      = "../../kong/compose.yaml"
    destination = "/home/tony/compose.yaml"
  },
  {
    source      = "../../kong/kong.yaml"
    destination = "/home/tony/kong.yaml"
  }
]

docker_hub_pass_dir      = "c:/key"                                                   # Dir holding the file with my docker password
docker_hub_pass_filename = "docker_hub_pass.txt"                                      # File holding my Docker password
docker_hub_user_name     = "oldgitdocker"                                             # Github user name
docker_install_dir       = "D:/oneDriveUclan/OneDrive - University of Lancashire/CO3404/Demos/all_scripts" # Dir holding docker install script
docker_install_script    = "docker-az-tf.sh"                                          # Filename of Docker install script
dest_dir                 = "/home/tony"                                               # Dest dir for scripts and .yaml
private_key_file         = "c:\\key\\az.pem"                                          # My private key file
push_images              = []                                                         # List of images to push to Docker hub
