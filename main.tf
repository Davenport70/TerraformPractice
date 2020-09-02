#==================================main tier====================================

provider "AWS" {
  region =  "eu-west-2"
}

#====================================== vpc ====================================
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

resource route_table_id
