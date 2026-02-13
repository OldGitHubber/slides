# Constants with local file scope to avoid repetition and improve maintenance
locals {
  london_ubuntu_20     = "ami-053a617c6207ecc7b"
  london_red_hat_9     = "ami-07d1e0a32156d0d21"
  london_SUSE_linux_15 = "ami-0ecd324438a088e0d"
  london_aws_linux     = "ami-0b31d93fb777b6ae6"
  london_region        = "eu-west-2"
  base_key             = "aws"
}

provider "aws" {
  region = local.london_region
}


# "call" the module to create the instance passing args to it
module "ec2-instance1" {
  source = "./modules/ec2-instance-creation"

  # Pass args to params. All params that don't have default must be passed
  machine-type = "t2.micro"
  image-type   = local.london_red_hat_9
  ssh-key      = local.base_key
  sg-name      = "junk-module-test-sg1"
  dest-dir     = "/home/ec2-user" # Destination of file copy to this vm
  start-script = "./test.sh"    # The file to be copied and run on vm. NOTE: scripts are OS dependant
  vm-name      = "junk-module-test-vm1"
  source-code  = "./test.txt" # This could be javascript, .yaml or whatever you need to copy to remote

  # Connection details for terraform to ssh into the remote machine. Pass this to the module
  connection-obj = {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("c:\\key\\aws.pem") # Path to your private key file
  }
}


# Output can be in this file or in outputs.tf file if preferred
output "vm1" {
  value = module.ec2-instance1.instance_public_ip
}

# output "vm2" {
#   value = module.ec2-instance2.instance_public_ip
# }


