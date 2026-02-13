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

# Output the VM public IP so we can log onto it
output "instance_public_ip" {
  value = aws_instance.vm.public_ip
}
