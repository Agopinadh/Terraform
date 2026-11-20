resource "aws_instance" "name" {
  ami                         = "ami-06f98347e4f9c7328"
  instance_type               = "t3.micro"
  for_each                    = toset(var.env)
  associate_public_ip_address = false
  tags = {
    Name = each.key
    Type = "private"
  }
}