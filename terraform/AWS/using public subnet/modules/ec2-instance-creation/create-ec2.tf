# This module creates an ec2 instance based on the parameters passed in
# It returns information about the ec2 instance to tne caller 
# terraform apply -auto-approve may be useful if you want to kick of and come back when finished

# Note: the file provisioners to copy and run the docker install script was in the ec2 resource
# That was fine until creating an elastic ip. The provisioners needed the ec2 IP address which when
# auto allocated, it could use self.public_ip no problem. However, when using elastic IP, the IP
# wasn't available as it hadn't been created. I moved the provisioners into their own null-resource
# and set a dependency on the ec2 and the elastic IP. This means referencing the public IP from 
# the elastic IP resource as opposed to the vm. 
#
# Because it uses several security rules, these have been delegated to a module
#
# Create security group. Created separate to rules so rules
# can be created independantly
resource "aws_security_group" "sg" {
  description = "Security group for EC2 instance with no rules specified"
  name        = var.sg-name
  vpc_id      = var.vpc-id
  tags = {
    Name = "demo-sg"
  }
}

# Create the network security rules using a module
module "rule_22" {
  source = "../security rules"
  from   = 22
  to     = 22
  sg_id  = aws_security_group.sg.id
}


# This is the default if using default resources. Everything can leave the subnet
# We need this to ping and for the vm to make outbound calls - e.g. download stuff
resource "aws_security_group_rule" "allow_all_proto_and_port" {
  type              = "egress"
  from_port         = 0             # because using all protocols, this means nothing
  to_port           = 0             # because using all protocols, this means nothing
  protocol          = "-1"          # -1 meand all protocols
  cidr_blocks       = ["0.0.0.0/0"] # from any ip address
  security_group_id = aws_security_group.sg.id
}

# Create an elastic IP if you want to keep your public IP address even if the machine is re-created
# Note: if you use terraform destroy it will destroy this too so you lose the IP
# There are ways round that - look it up
resource "aws_eip" "demo_eip" {
  tags = {
    Name = "demo-eip"
  }
}

# The vm may be attached to several security groups. e.g. one for ssh for all ec2
# one with 3306 for all mysql instaces. For a simple case like this, one security group is fine
resource "aws_instance" "vm" {
  ami                    = var.image-type
  instance_type          = var.machine-type
  key_name               = var.ssh-key                # Name of the public key in aws if there is one
  vpc_security_group_ids = [aws_security_group.sg.id] # List of security groups the vm is associated with
  subnet_id              = var.subnet-id              # Deploy in here. It's in a specific az. 

  # Could create a disk here or rely on the default which aws will base on the image
  # If using, pass parameters for type and size etc. Just left in here for illustration
  # root_block_device {
  #   volume_type           = "gp3"  # General purpose ssd
  #   volume_size           = 30     # Size in GB. 30GB is max for free
  #   delete_on_termination = true   # Delete when instance is deleted
  #   encrypted             = true
  # }

  tags = {
    Name = var.vm-name # Optionally name the instance. Used in search or is seen in the console
  }
}


# Example of a file provisioner and remote-exec to run the file
# Copy file to remote vm. Uses scp in the background. Syntax is:
# scp -i path_to_secret_key path_to_local_file username@host_name:path_to_remote_file
# In this case it's to copy a provided start script - e.g. install node or docker or whatever
resource "null_resource" "boot-script" {
  depends_on = [aws_eip.demo_eip, aws_instance.vm] # Make sure there is a vm with an IP to copy to and login

  provisioner "file" {
    source      = var.start-script                      # path_to_local_file
    destination = "${var.dest-dir}/${var.start-script}" # path_to_remote_file. This varies by OS
    connection {
      type        = "ssh"
      user        = var.connection-obj.user        # username. e.g. ubuntu or ec2-user
      private_key = var.connection-obj.private_key # path_to_secret_key
      host        = aws_eip.demo_eip.public_ip
    }
  }


  # Simple demo of local-exec just for the sake of it
  provisioner "local-exec" {
    command = "echo PUBLIC IP = ${aws_eip.demo_eip.public_ip}"
  }


  # Execute commands on the remote. This example runs the script
  # copied by the file provisioner
  provisioner "remote-exec" {
    inline = [
      "cd ${var.dest-dir}",
      "bash ${var.start-script}"
    ]

    connection {
      type        = "ssh"
      user        = var.connection-obj.user
      private_key = var.connection-obj.private_key
      host        = aws_eip.demo_eip.public_ip
    }
  }
}


# If you stop and restart your instance you will lose your public IP
# To avoid that, create an elastic IP which is a static IP address
# Associate the Elastic IP with the ec2 Instance
# Note: you are charged if eip is not associated to a running vm
# Charge is very small $0.005 / hour
# or about $3.60 / month - stops wastage of public IP addresses
resource "aws_eip_association" "eip_ec2" {
  instance_id   = aws_instance.vm.id
  allocation_id = aws_eip.demo_eip.id
}

# Return a set of instance attributes
output "vm-info" {
  value = {
    name          = aws_instance.vm.tags.Name
    instance_type = aws_instance.vm.instance_type
    instance_id   = aws_instance.vm.id
    user          = var.connection-obj.user
    private_ip    = aws_instance.vm.private_ip
    public_ip     = aws_eip.demo_eip.public_ip
  }
}

