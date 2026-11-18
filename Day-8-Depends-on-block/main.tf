
# -------------------------
# EC2 INSTANCE
# -------------------------

resource "aws_instance" "name" {
  ami                    = "ami-00f43ee0e98d52529"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.name.id]
  subnet_id              = aws_subnet.name.id

  tags = {
    Name = "my-ec2-instance"
  }
}

# -------------------------
# SECURITY GROUP
# -------------------------

resource "aws_security_group" "name" {
  name        = "my-security-group"
  description = "Allow SSH Traffic"
  vpc_id      = aws_vpc.name.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-security-group"
  }
}

# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "name" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# -------------------------
# SUBNET
# -------------------------

resource "aws_subnet" "name" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "my-subnet"
  }
}

# -------------------------
# S3 BUCKET
# -------------------------

resource "aws_s3_bucket" "name" {
  bucket = "charoit"
  depends_on = [ aws_instance.name ]

  tags = {
    Name = "my-s3-bucket"
  }
}
