terraform {
  backend "s3" {
    bucket       = "bucket-state-lock"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    dynamodb_table = "nani"
    encrypt      = true
    #use_lockfile = true
    description  = "This is a test for remote backend with state lock"
  }
}
