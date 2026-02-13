# This code will create an AWS ec2 instance using default values - like doing it in the console

# Provider is AWS London
provider "aws" {
    region = "eu-west-2"  # Credentials for Terraform are on local machine with aws configure
}

# Create security group to open port 22 to enable ssh access to the vm
resource "aws_security_group" "demo-sg" {
  name        = "junk-sg" # Name of the security group as seen in the console
  description = "Security group for EC2 instance"

  # Inbound rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere
  }
}

# Create an EC2 instance called junk based on t2.micro and ubuntu 24.04 using ssh keys called aws and security group junk-sg
resource "aws_instance" "demo-vm" {
    # ami           = "ami-053a617c6207ecc7b"  # Ubuntu 24.04. Choose what you want
    ami = "ami-0c0493bbac867d427" # Amazon linux
    instance_type = "t2.micro" # The free one. Choose what you want
    key_name = "aws" # Key pair name as stored in AWS if you have one. As you would select it in the console
    vpc_security_group_ids = [aws_security_group.demo-sg.id] # this references the sg block called junk-sg to link to ec2 by unique id
    tags = {
      Name = "junk" # tag the instance if you want
    }
}
    

# Output the VM public IP so we can log onto it
output "instance_public_ip" {
  value = aws_instance.demo-vm.public_ip
}
