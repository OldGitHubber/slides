
# subscription_id available from console or: az account show --query id --output tsv
# From console, search for subscription
subscription = "5645f4b2-db38-4326-b7a6-98d374ebdd9c"

assign_public_ip = true # Set to false if you do not want to assign a public IP and true if you do

publicIP = {
  name = "app1"
  type = "Static" # If using dynamic, sku needs to be basic
  sku  = "Standard"
  domain_name = "tnapp1" # Cannot be null. azure will create tnapp1.region.cloudapp.azure.com
}

nsg_name = "app1"


inbound_security_rule = {
  name       = "all-app-ports"
  priority   = 1000
  dest_ports = ["22","4001"] 
}

ip_config_name = "app1"

# ******* If more than one subnet available in the vnet creation, the subnet names are in the vnet 
# ******* terraform state file so need to make sure that the main.tf file for this project references
# ******* the correct subnet. A clue is if the build creates an error that the IP is not in the subnet
# ******* e.g., in this case, main.tf line subnet_id = data.terraform_remote_state.vnet-state.outputs.subnet1_id 
# ******* needs to reflect the subnet name you want this VM to be placed in. subnet(x)_id is in the vnet teraform.tfvars
# Type can be Static or Dynamic. If Static, need an IP. If Dynamic, address=null
private_ip = {
  type    = "Static"
  address = "10.0.1.4"
}

vm_spec = {
  name       = "app1"
  size       = "Standard_B1s" # The free one. Choose B2s for database
  admin-name = "tony"
}


disk_spec = {
  caching-type = "ReadWrite"
  storage-type = "Standard_LRS" # spinning rust - free
  size-gb      = "30"           # Ubuntu 20 min 25GB. 10 GB for mysql if using it. 1-2 GB for node containers. RabitMQ about 20GB + 20%
}

OS_image = {
  publisher = "Canonical"
  type      = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
  version   = "latest" # e.g., Latest 20.04 including minor version updates
}

pub_key = "c:/key/az.pub"

# Now for the variables for the CI/CD part
compose_source_dir       = "../../app1"
compose_filename         = "compose.yaml"

# Provide a list of files to copy to the VM
copy_config = [
  {
    source      = "../../app1/compose.yaml"
    destination = "/home/tony/compose.yaml"
  },
  #{
   # any other files
   # source      = ""
   # destination = ""
  #}
]

docker_hub_pass_dir      = "c:/key"
docker_hub_pass_filename = "docker_hub_pass.txt"
docker_hub_user_name     = "oldgitdocker"

docker_install_file = {
  base_dir = "C:\\Users\\tonyn\\OneDrive - UCLan" # find this with echo $Env:OneDrive
  file_dir = "CO3404/Demos/all_scripts"
  file_name ="docker-az-tf-swap.sh"
}

dest_dir                 = "/home/tony"
private_key_file         = "c:\\key\\az.pem"
push_images              = ["oldgitdocker/app1:latest"]
