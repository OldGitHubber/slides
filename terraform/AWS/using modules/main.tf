# This file creates two different ec2 instaces using a module

# Constants with local file scope
locals {
  london_ubuntu_20 = "ami-053a617c6207ecc7b"
  london_red_hat_9 = "ami-07d1e0a32156d0d21"
  london_SUSE_linux_15 = "ami-0ecd324438a088e0d"
  london_region    = "eu-west-2"
  base_key         = "aws"
}

provider "aws" {
  region = local.london_region
}

# "call" the module to create the instance passing args to it
module "ec2-instance1" {
  source = "./modules/ec2-instance" # use web link if in github

  # Pass args to params
  machine-type = "t2.medium"
  image-type   = local.london_red_hat_9
  ssh-key      = local.base_key
  sg-name      = "junk-module-test-sg1"
  vm-name      = "junk-module-test-vm1"
}

# "call" the module to create the instance passing args to it
module "ec2-instance2" {
  source = "./modules/ec2-instance" # use web link if in gthub

  # Pass args to params
  machine-type = "t2.large"
  image-type   = local.london_ubuntu_20
  ssh-key      = local.base_key
  sg-name      = "junk-module-test-sg2"
  vm-name      = "junk-module-test-vm2"
}

output "vm1" {
  value = module.ec2-instance1.instance_public_ip
}

output "vm2" {
  value = module.ec2-instance2.instance_public_ip
}

output "vm1-info" {
  value = module.ec2-instance1.vm-info
}

output "vm2-info" {
  value = module.ec2-instance2.vm-info
}