
variable "name" {
  description = "Prefix for resource names; use lowercase letters, digits, and hyphens."
  type        = string
  default     = "day15-app"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.name))
    error_message = "Name must contain lowercase letters, digits, and hyphens, and start and end with a letter or digit."
  }
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = contains(["us-east-1", "us-west-1"], var.aws_region)
    error_message = "The AWS region must be us-east-1 or us-west-1."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the private VPC."
  type        = string
  default     = "10.30.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Please provide a valid IPv4 CIDR block."
  }
}

variable "db_instance_class" {
  description = "RDS MySQL instance class."
  type        = string
  default     = "db.t3.micro"
}
