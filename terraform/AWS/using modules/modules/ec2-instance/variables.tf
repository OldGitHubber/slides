# Module variable declarations and optional defaults 

variable "machine-type" {
  type = string
  default = "t2.micro"
}

variable "image-type" {
  type = string
  default = "ami-053a617c6207ecc7b"
}

variable "ssh-key" {
  type = string
  default = "aws"
}

variable "sg-name" {
  type = string
  default = "junk"
}

variable "vm-name" {
  type = string
  default = "junk"
}

