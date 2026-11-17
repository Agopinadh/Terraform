resource "aws_instance" "name" {
  ami           = "ami-096ef200a877f36af"
  instance_type = "t2.micro"

  tags = {
    Name = "MyInstance"
  }
  lifecycle {
  create_before_destroy = true
  }
  #lifecycle {
   # ignore_changes = [tags, ]
  #}
  #lifecycle {
  # prevent_destroy = true
  #}
}