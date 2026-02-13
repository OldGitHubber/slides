# Module variable declarations and optional defaults 
# Defaults can be used but be careful. If you forget to 
# provide a parameter, a default will be used which may not
# be what you wanted

variable "machine-type" {
  type = string
#  default = "t2.micro"
}

variable "image-type" {
  type = string
#  default = "ami-053a617c6207ecc7b"
}

variable "ssh-key" {
  type = string
#  default = "aws"
}

variable "vm-name" {
  type = string
#  default = "junk"
}

variable "sg-name" {
  type = string
#  default = "junk"
}

variable "start-script" {
  type = string
}

# variable "source-code" {
#   type = string
# }

variable "dest-dir" {
  type = string
}

variable "connection-obj" {
  type = object ({
    user        = string
    private_key = string
  })
}

variable "subnet-id" {
  type = string
}

variable vpc-id {
  type = string
}