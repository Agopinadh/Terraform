#Creation of S3 Bucket
resource "aws_s3_bucket" "Lambda-bucket" {
  bucket        = "my-lambda-bucket"
  force_destroy = true
  tags = {
    Name = "Lambda-bucket"
  }
}

resource "aws_s3_bucket_acl" "Lambda-bucket_acl" {
  bucket = aws_s3_bucket.Lambda-bucket.id
  acl    = "private"
}

#update lambda code to S3
