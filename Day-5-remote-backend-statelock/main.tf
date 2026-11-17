resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "vpc-terraform"
  }
}

resource "aws_subnet" "name1" {
  vpc_id     = aws_vpc.name.id
  cidr_block = "10.0.0.0/26"

  tags = {
    Name = "subnet-terraform1"
  }
}

resource "aws_subnet" "name2" {
  vpc_id     = aws_vpc.name.id
  cidr_block = "10.0.0.64/26"

  tags = {
    Name = "subnet-terraform2"
  }
}
