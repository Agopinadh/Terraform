variable "name" {
  description = "Prefix used for resource names and tags."
  type        = string
  default     = "production-web"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,19}$", var.name))
    error_message = "name must be 3-20 characters, start with a lowercase letter, and contain only lowercase letters, digits, or hyphens."
  }
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region for regional resources. CloudFront certificates, when used, must be in us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC; must be a /16 or larger network."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && tonumber(split("/", var.vpc_cidr)[1]) <= 16
    error_message = "vpc_cidr must be a valid IPv4 CIDR with a prefix length of /16 or smaller."
  }
}

variable "instance_type" {
  description = "EC2 instance type used by the application Auto Scaling group."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of application instances."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of application instances."
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Initial desired number of application instances."
  type        = number
  default     = 2
}

variable "db_instance_class" {
  description = "RDS MySQL instance class for the primary and read replica."
  type        = string
  default     = "db.t3.micro"
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t4g.micro"
}

variable "deletion_protection" {
  description = "Protect the RDS primary from accidental deletion."
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Optional existing Route 53 hosted zone ID for the CloudFront alias record."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Optional fully qualified domain name for CloudFront, such as app.example.com."
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN for the CloudFront domain; certificate must be in us-east-1."
  type        = string
  default     = ""
}

variable "peer_vpc_id" {
  description = "Optional same-account, same-region VPC ID for direct VPC peering."
  type        = string
  default     = ""
}

variable "peer_vpc_cidr" {
  description = "CIDR block for the optional directly peered VPC; its owner must add the return route."
  type        = string
  default     = ""
}

variable "enable_transit_gateway" {
  description = "Create a Transit Gateway and attach this VPC; additional VPCs require their own attachments."
  type        = bool
  default     = false
}

variable "transit_gateway_routes" {
  description = "Optional static routes: destination CIDR => existing attachment ID on the created Transit Gateway."
  type        = map(string)
  default     = {}
}
