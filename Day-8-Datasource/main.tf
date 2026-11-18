

data "aws_subnet" "selected" {
    filter {
      name = "tag:Name"
      values = ["subnet-1"] # Replace with your actual subnet name
    
    }
  
}

data "aws_security_group" "name" {
    filter{
        name = "tag:Name"
        values= ["my-security-group"] # Fetch the security group wit the tag Name = my-security-group
    }
  
}


# -------------------------
# EC2 INSTANCE
# -------------------------

resource "aws_instance" "name" {
  ami                    = "ami-00f43ee0e98d52529"
  instance_type          = "t2.micro"
  vpc_security_group_ids = data.aws_security_group.selected.id
  subnet_id              = data.aws_subnet.selected.id

  tags = {
    Name = "my-ec2-instance"
  }
}



