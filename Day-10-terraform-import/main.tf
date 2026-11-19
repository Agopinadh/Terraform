resource "aws_instance" "name" {
    ami = "ami-06f98347e4f9c7328"
    instance_type = "t3.micro"
    tags = {
      Name = "ec2"
    }
}

resource "aws_s3_bucket" "name" {
    bucket = "chariot9"

  
}

resource "aws_s3_bucket_versioning" "name" {
    bucket = aws_s3_bucket.name.id
    versioning_configuration {
      status = "Enabled"
    }
  
}