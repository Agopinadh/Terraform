terraform {
  backend "s3" {
    bucket = "bucket-state-lock"
    key    = "terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    }
}
