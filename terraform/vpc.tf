/*
*
*      VPC, Subnet, Route Table, IGW, NAT, and Security Group creation
*
*/

# VPC Resource
resource "aws_vpc" "project3_vpc" {
  cidr_block                = "10.1.0.0/16"
  enable_dns_hostnames      = true

  tags = {
      Name = "IS531 Project 3 VPC"
  }
}
# Public Subnet Resource
resource "aws_subnet" "public" {
  vpc_id                    = aws_vpc.project3_vpc.id
  cidr_block                = "10.1.1.0/24"
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.available.names[1]


  tags = {
      Name = "IS531 Public Subnet"
  }
}

data "aws_availability_zones" "available" {
  state                     = "available"
}

# Public Subnet Resource
resource "aws_subnet" "public2" {
  vpc_id                    = aws_vpc.project3_vpc.id
  cidr_block                = "10.1.2.0/24"
  availability_zone         = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch   = true

  tags = {
      Name = "IS531 Public2 Subnet"
  }
}

# 2nd Private Subnet Resource for DB instance (Aurora requires subnets in 2 AZs)
resource "aws_subnet" "private" {
  vpc_id                    = aws_vpc.project3_vpc.id
  cidr_block                = "10.1.3.0/24"
  availability_zone         = data.aws_availability_zones.available.names[1]

  tags = {
      Name = "IS531 Private Subnet 2"
  }
}

# Resource for Internet Gateway for Public Subnet
resource "aws_internet_gateway" "project3_igw" {
  vpc_id                    = aws_vpc.project3_vpc.id

  tags = {
      Name = "IS531 Main IGW"
  }
}
# Elastic IP for NAT Gateway for Private Subnet
resource "aws_eip" "project3_nat_eip" {
  vpc                       = true
  depends_on                = [aws_internet_gateway.project3_igw]

  tags = {
      Name = "IS531 NAT Gateway EIP"
  }
}

# NAT Gateway for VPC
resource "aws_nat_gateway" "project3_nat" {
  allocation_id             = aws_eip.project3_nat_eip.id
  subnet_id                 = aws_subnet.public.id

  tags = {
      Name = "IS531 Main NAT Gateway"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id                    = aws_vpc.project3_vpc.id

  route {
    cidr_block              = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.project3_igw.id
  }

  tags = {
      Name = "IS531 Public Route Table"
  }    
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id                    = aws_vpc.project3_vpc.id

  route {
    cidr_block              = "0.0.0.0/0"
    gateway_id              = aws_nat_gateway.project3_nat.id
  }

  tags = {
    Name = "IS531 Private Route Table"
  }
}

# Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id                 = aws_subnet.public.id
  route_table_id            = aws_route_table.public.id
}

# Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "Public2" {
  subnet_id                 = aws_subnet.public2.id
  route_table_id            = aws_route_table.public.id
}

# Association between Private Subnet and Private Route Table
resource "aws_route_table_association" "private" {
  subnet_id                 = aws_subnet.private.id
  route_table_id            = aws_route_table.private.id
}

# Compute Security Group
# resource "aws_security_group" "ec2_sg" {
#   name                      = "ec2_security_group"
#   description               = "Security Group for EC2 webserver instance for SSH and HTTP/HTTPS traffic"
#   vpc_id                    = aws_vpc.project3_vpc.id

#   ingress {
#     from_port               = 22
#     to_port                 = 22
#     protocol                = "tcp"
#     cidr_blocks             = ["10.0.0.0/18", "0.0.0.0/0"]
#   }
  
#   ingress {
#     from_port               = 8000
#     to_port                 = 8000
#     protocol                = "tcp"
#     cidr_blocks             = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port               = 443
#     to_port                 = 443
#     protocol                = "tcp"
#     cidr_blocks             = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port               = 0
#     to_port                 = 0
#     protocol                = "-1"
#     cidr_blocks             = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "EC2 Security Group"
#     security_group = "ec2_sg"
#   }
# }

# RDS Security Group
resource "aws_security_group" "db_sg" {
  name                      = "is531_db_security_group"
  description               = "DB security group for RDS and SSH traffic over ports 3306 and 22"
  vpc_id                    = aws_vpc.project3_vpc.id
  
  ingress {
    from_port               = 3306
    to_port                 = 3306
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }

  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }

  tags = {
    Name = "IS531 DB Security Group"
    security_group = "rds_sg"
  }
}
