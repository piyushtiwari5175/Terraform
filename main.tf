terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "demo-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo-igw"
  }
}

# Public Subnet with automatic public IP assignment
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "10.10.1.0/24"
  map_public_ip_on_launch = true  # Auto-assigns public IPs

  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.10.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

# Route Table for Public Subnet 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table for Private Subnet (no Internet Gateway route)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# EC2 Instance in Public Subnet
resource "aws_instance" "public_instance" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id  # Launches in the public subnet

  tags = {
    Name = "public-instance"
  }
}

# EC2 Instance in Private Subnet
resource "aws_instance" "private_instance" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id  # Launches in the private subnet

  tags = {
    Name = "private-instance"
  }
}

