# Input parameters:
#   machine-type: e.g. t2.micro
#   image-type: e.g. "ami-053a617c6207ecc7b" - these are regionally different
#   ssh-key: the name of the key managed by the provider if you created one
#   vm-name: name tag of the vm
#   sg-name: any name to call the VM's security group
#   start-script: file to be copied to remote and executed only during creation
#   source-code: file to be copied to remote but not executed. Copied again if it changes
#   dest-dir: destination of files to be copied to the remote machine
#   connection-obj: object with all any variable ssh connection info

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

  # Copy file to remote vm
  provisioner "file" {
    source      = var.start-script # Source for scp
    destination = "${var.dest-dir}/${var.start-script}" # dest for scp
    connection {
      type = "ssh"
      user = var.connection-obj.user
      private_key = var.connection-obj.private_key
      host = self.public_ip
    }
  }

  # Simple dem of local-exec just for the sake of it
  provisioner "local-exec" {
    command = "echo PUBLIC IP = ${self.public_ip}"
  }

  # Execute the file copied to the vm
  provisioner "remote-exec" {
    inline = [
      "cd ${var.dest-dir}",
      "bash ${var.start-script}"
    ]

     connection {
      type = "ssh"
      user = var.connection-obj.user
      private_key = var.connection-obj.private_key
      host = self.public_ip
    }
  }
}

# Example of a null-resource to just copy a file - e.g. a compose.yaml file rather than using winscp or scp
resource "null_resource" "copy_file" {
  triggers = {
    file_md5 = filemd5(var.source-code) # If hash has changed then so have contents so trigger this resource
  }

 # Copy file to remote vm
  provisioner "file" {
    source      = var.source-code # Source for scp
    destination = "${var.dest-dir}/${var.source-code}" # dest for scp
    connection {
      type = "ssh"
      user = var.connection-obj.user
      private_key = var.connection-obj.private_key
      host = aws_instance.vm.public_ip 
    }
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

