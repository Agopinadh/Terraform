terraform {
  backend "s3" {
    bucket = "bucket-state-backend"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
