resource "aws_instance" "name" {
  ami           = "ami-0aacbf72109c53c0c"
  instance_type = "t3.micro"
  tags = {
    Name = "OpenTofu-Instance"
  }

}