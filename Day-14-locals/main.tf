locals {
  region        = var.region
  instance_type = "t3.micro"
  ami           = "ami-0aacbf72109c53c0c"
}

resource "aws_instance" "name" {
  ami           = local.ami
  instance_type = local.instance_type
  region        = local.region

}