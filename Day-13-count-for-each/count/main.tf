variable "env" {
    type = list(string)
    default = [ "dev", "test","prod" ]
}


resource "aws_instance" "name" {
  ami           = "ami-06f98347e4f9c7328"
  instance_type = "t3.micro"
  #count = 2
  count         = length(var.env)
  tags = {
    Name = var.env[count.index]
  }
}