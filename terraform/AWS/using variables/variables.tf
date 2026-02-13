variable "region" {
  default = "eu-west-2"
}

variable "machine-type" {
  default = "t2.medium"
}

variable "image-type" {
  default = "ami-053a617c6207ecc7b"
}

variable "ssh-key" {
  default = "tony"
}

variable "vm-name" {
  default = "junk"
}

variable "sg-name" {
  default = "junk"
}


provider "aws" {
  region = var.region 
}