# Constants with local file scope to avoid repetition and improve maintenance
locals {
  london_ubuntu_20 = "ami-053a617c6207ecc7b"
  london_red_hat_9 = "ami-07d1e0a32156d0d21"
  london_SUSE_linux_15 = "ami-0ecd324438a088e0d"
  london_aws_linux = "ami-0c0493bbac867d427"
  london_region    = "eu-west-2"
  base_key         = "aws"
}

provider "aws" {
  region = local.london_region
}

# Create a virtual private cloud - i.e. a virtual private network within which our resources will be accessible
# A default route table will be created and used of we don't creat our own
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16" # Could use /8 but /16 gives us loads and up to 256 interconnected VPCs
  tags = {
    Name = "demo-vpc"
  }
}

# Create a gateway so users can access our VM and our vm can access the internet
# This acts as a 1-2-1 NAT. It will convert the public ip arriving at the AWS public
# network into a private IP of the ec2 by looking up the private IP associated to the
# public ip in the NIC or elastic IP
# On egress, the local/private ip is trantlated into a public ip
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    Name = "demo-igw"
  }
}

# Need a route table to hold outbound routing info in the vpc like a route table in a router
# As a subnet is a different network to the vpc, we need to create a route from the
# subnet to the gateway to allow a route between them
resource "aws_route_table" "demo_route_table" {
  vpc_id = aws_vpc.demo_vpc.id # Associate this route table with the vpc to route traffic to/from it

  route {
    cidr_block = "0.0.0.0/0"                      # Traffic out to any IP on the public internet
    gateway_id = aws_internet_gateway.demo_igw.id # Traffic target is igw
  }

  tags = {
    Name = "demo-route-table"
  }
}

# May want to create a module if you have several subnets
# This is a public subnet as we want its resources to have access to the
# internet. As such, we will need to "connect it" to the gateway via the route table
# Note: a subnet nacl can be defined in this file but one is created by deffault with
# no rules which means allow everything in both directions. If one is cretated here
# inbound and outbound rules need to be defined. No point unless you want to block
# something. Unlike ACL, these are enabled until disabled. They are stateless so ingress
# and egress need to be defined. It works at the subnet level.
# ACL is statefuland disabled by default. You write enabling rules. If you write an 
# ingress or egress rule, a response is automatically enabled. 
# The subnet is associated with a specific AZ so any instance created in this subnet ends up in this AZ
resource "aws_subnet" "demo_public_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id        # link the subnet to the vpc
  cidr_block              = "10.0.1.0/24"              # Choose your subnet range
  map_public_ip_on_launch = false                      # False if using elastic IP true if not or you will get two        
  availability_zone       = "${local.london_region}a"  # London has a, b and c. Locate the subnet and its resources here

  tags = {
    Name = "demo-public-subnet"
  }
}

# Need to link the subnet to the route table (a bit like conecting it to a router)
# The route table is linked to vpc and the internet gateway 
resource "aws_route_table_association" "demo_subnet_association" {
  subnet_id      = aws_subnet.demo_public_subnet.id 
  route_table_id = aws_route_table.demo_route_table.id
}



# "call" the module to create the instance passing args to it
module "ec2-instance1" {
  source = "./modules/ec2-instance-creation"

  # Pass args to params. All params that don't have default must be passed
  machine-type = "t2.micro"
  image-type   = local.london_aws_linux
  ssh-key      = local.base_key
  sg-name      = "demo-sg"
  dest-dir     = "/home/ec2-user"       # Destination of file copy to this vm
  start-script = "./docker-inst-aws.sh" # The file to be copied and run on vm
  vm-name      = "ec2-instance1"
  subnet-id = aws_subnet.demo_public_subnet.id # Link the ec2 to the public subnet and on to the gateway
  vpc-id = aws_vpc.demo_vpc.id          # Place ec2 in correct network & vpc-wide rules eg vpc nacl apply to all in the network
  
  # Connection details for terraform to ssh into the remote machine. Pass this to the module
  connection-obj = {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("c:\\key\\aws.pem") # Path to your private key file
  }
}


output "vm-attributes" {
  value = module.ec2-instance1.vm-info
}


