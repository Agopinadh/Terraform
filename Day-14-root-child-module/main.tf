provider "aws" {
  region = "us-east-1"

}

module "server" {
  source        = "./modules/ec2"
  instance_name = "my-server"
  ami_id        = "ami-0aacbf72109c53c0c"
  instance_type = "t3.micro"
}