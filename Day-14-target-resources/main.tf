resource "aws_instance" "name" {
  ami           = "ami-06f98347e4f9c7328"
  instance_type = "t3.micro"
  tags = {
    Name = "DEV"
  }
}

resource "aws_s3_bucket" "name" {
  bucket = "addagada9"

}

# terraform apply -auto-approve -target=aws_s3_bucket.name we can target a specific resource to create.
# terraform destroy -auto-approve -target=aws_s3_bucket.name we can target a specific resource to destroy.
