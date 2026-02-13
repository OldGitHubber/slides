# Input parameters:
#   sg-name: any name to call the VM's security group
#   image-type: e.g. "ami-053a617c6207ecc7b" - these are regionally different
#   machine-type: e.g. t2.micro
#   ssh-key: the name of the key managed by the provider if you created one
#   machine-name: name tag of the vm

# Output parameters
#   instance_public_ip: returns the VM public IP as a string
#   vm-info: returns an object with various vm properties as members


# Create security group to open port 22 to enable ssh
resource "aws_security_group" "sg" {
  name        = var.sg-name 
  description = "Security group for EC2 instance"

  # Inbound rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere
  }
}

resource "aws_instance" "vm" {
  ami                    = var.image-type             
  instance_type          = var.machine-type           
  key_name               = var.ssh-key                
  vpc_security_group_ids = [aws_security_group.sg.id] 
  tags = {
    Name = var.vm-name # name the instance
  }
}


# Output the VM public IP so we can log onto it. In a module this is returned to the root main.ts
output "instance_public_ip" {
  value = aws_instance.vm.public_ip
}

output "vm-info" {
  value = {
    name          = aws_instance.vm.tags.Name
    instance_type = aws_instance.vm.instance_type
    instance_id   = aws_instance.vm.id
    private_ip    = aws_instance.vm.private_ip
    public_ip     = aws_instance.vm.public_ip
  }
}

