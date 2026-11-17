terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "archive_file" "api_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/.terraform/api_lambda.zip"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  subnet_cidrs = {
    public = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, i)]
    app    = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, i + 16)]
    data   = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, i + 32)]
  }
}
