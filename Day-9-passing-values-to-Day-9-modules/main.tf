module "ec2" {
  source = "../Day-9-modules"

  ami_id             = "ami-00f43ee0e98d52529"
  instance_type      = "t3.micro"
  subnet_id          = "subnet-01ebf7596ec39ce3f"
  security_group_ids = ["sg-0eec593db9fc01fca"]
  instance_name      = "my-ec2-instance"
  environment        = "dev"
}