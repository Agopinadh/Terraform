module "test" {
  source        = "../Day-9-modules"
  instance_type = "t3.micro"
  instance_name = "test-instance"
  ami_id        = "ami-00f43ee0e98d52529"
  security_group_ids = ["sg-023d91c6e5ade621f"]
  subnet_id = "subnet-0d564b2e006453ab8"
}