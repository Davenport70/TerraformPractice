#==================================main tier====================================

provider "aws" {
  region =  "eu-west-2"
}

#====================================== vpc ====================================
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}
#====================================== igw ====================================

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-ig"
  }
}
#==================================== routetable ===============================

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

#==================================== publicsubnet =============================

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main-public-subnet"
  }
}
