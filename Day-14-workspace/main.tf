resource "aws_instance" "name" {
  ami           = "ami-06f98347e4f9c7328"
  instance_type = "t3.micro"
  tags = {
    Name = "asdfghjk"
  }

}