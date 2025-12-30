provider "aws" {
  region = "eu-west-2"
}
###############################
#           SSH KEY           #
###############################
resource "aws_key_pair" "student_key" {
  key_name   = "student_key"
  public_key = file("~/.ssh/student_key.pub")
}
###########################
#           VPC           #
###########################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "student-vpc"
  }
}

#####################################
#           Public Subnet           #
#####################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/25"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"
  tags = {
    Name = "student-public-subnet"
  }
}

######################################
#           Private Subnet           #
######################################
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "student-private-subnet"
  }
}

########################################
#           Internet Gateway           #
########################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "student-igw"
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
    Name = "student-public-rt"
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
resource "aws_security_group" "web" {
  vpc_id      = aws_vpc.main.id
  name        = "student-web-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
  ami                         = "ami-0a0ff88d0f3f85a14"
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.student_key.key_name


  tags = {
    Name = "student-ubuntu"
  }
}



