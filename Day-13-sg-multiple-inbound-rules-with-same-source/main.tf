resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My-VPC"
  }

}

resource "aws_subnet" "name" {
  vpc_id     = aws_vpc.name.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "My-Subnet1"
  }

}

# Creation of security group
resource "aws_security_group" "name" {
  name        = "my-security-group"
  description = "security group with multiple inbound rules from same source"
  vpc_id      = aws_vpc.name.id


  ingress = [

    for port in [22, 80, 443, 3306] : {
      description      = "Allow HTTP traffic from anywhere"
      from_port        = port
      to_port          = port
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      self             = false
    }
  ]
  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My-SG"
  }
}


resource "aws_instance" "name" {
  ami                    = "ami-06f98347e4f9c7328"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.name.id]
  subnet_id              = aws_subnet.name.id
  tags = {
    Name = "My-EC2-Instance"
  }

}