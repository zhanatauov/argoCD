provider "aws" {
  region = "eu-central-1"
}

###########################
#           VPC           #
###########################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "argo-vpc"
  }
}

#####################################
#           Public Subnet           #
#####################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/25"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
  tags = {
    Name = "argo-public-subnet"
  }
}

########################################
#           Internet Gateway           #
########################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "argo-igw"
  }
}

###################################
#           Route Table           #
###################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "argo-public-rt"
  }
}

###############################################
#           Route Table Association           #
###############################################
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

######################################
#           Security Group           #
######################################
resource "aws_security_group" "allow_ssh_http" {
  vpc_id      = aws_vpc.main.id
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

####################################
#            EC2 INSTANCE          #
####################################
resource "aws_instance" "my_instance_ubuntu" {
  ami                         = "ami-004e960cde33f9146"
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  key_name = "argo" 

  user_data = file("user_data.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "argo-ubuntu"
  }
  
  provisioner "local-exec" {
command = "echo Instance Public IP: ${self.public_ip}"
  } 
}



