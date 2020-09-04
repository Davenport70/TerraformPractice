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

#==================================== routeassoc =====================================

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.route_table.id
}

#==================================== NACL =====================================

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  #egress {
  #  protocol   = "tcp"
  #  rule_no    = 100
  #  action     = "allow"
  #  cidr_block = "10.3.0.0/18"
  #  from_port  = 53
  #  to_port    = 53
  #}

    egress {
      protocol   = "tcp"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 443
      to_port    = 443
    }

    egress {
      protocol   = "tcp"
      rule_no    = 200
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 80
      to_port    = 80
    }


  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  #ingress {
  #  protocol   = "tcp"
  #  rule_no    = 300
  #  action     = "allow"
  #  cidr_block = "10.3.0.0/18"
  #  from_port  = 53
  #  to_port    = 53
  #}

  tags = {
    Name = "main"
  }
}
  #==================================== EC2 =====================================

  resource "aws_instance" "web" {
    ami           = var.ami
    instance_type = "t2.micro"
    subnet_id = aws_subnet.main.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.allow_tls.id]


    tags = {
      Name = "terraform-practice-ec2"
    }
  }

  #==================================== SG =====================================

  resource "aws_security_group" "allow_tls" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.main.id

    ingress {
      description = "TLS from VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [aws_vpc.main.cidr_block]
    }

    ingress {
      description = "80 from VPC"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [aws_vpc.main.cidr_block]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "allow_tls"
    }
  }
