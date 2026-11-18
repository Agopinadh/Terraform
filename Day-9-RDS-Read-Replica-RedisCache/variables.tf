variable "aws_region" {
  description = "AWS Region in which to create the network and data services."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Short prefix used for AWS resource names."
  type        = string
  default     = "prod-app"

  validation {
    condition     = length(var.name_prefix) <= 32 && can(regex("^[a-z][a-z0-9-]*$", var.name_prefix))
    error_message = "name_prefix must start with a lowercase letter, contain only lowercase letters, digits, or hyphens, and be at most 32 characters."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range for the private VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs; use one subnet per Availability Zone, with at least two."
  type        = list(string)
  default     = ["10.40.0.0/20", "10.40.16.0/20", "10.40.32.0/20"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnet CIDRs are required for database and cache subnet groups."
  }
}

variable "db_identifier" {
  description = "Identifier for the MySQL primary DB instance."
  type        = string
  default     = "prod-app-mysql"
}

variable "db_engine_version" {
  description = "MySQL engine version; update this to a currently supported version in the selected Region."
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Instance class for the MySQL primary."
  type        = string
  default     = "db.r6g.large"
}

variable "db_replica_instance_class" {
  description = "Instance class for the MySQL read replica."
  type        = string
  default     = "db.r6g.large"
}

variable "db_allocated_storage" {
  description = "Initial allocated database storage in GiB."
  type        = number
  default     = 100
}

variable "db_max_allocated_storage" {
  description = "Maximum autoscaled database storage in GiB."
  type        = number
  default     = 500
}

variable "db_name" {
  description = "Initial MySQL database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username; the password is managed by Amazon RDS in Secrets Manager."
  type        = string
  default     = "dbadmin"
}

variable "cache_engine_version" {
  description = "Redis OSS engine version supported in the selected Region."
  type        = string
  default     = "7.1"
}

variable "cache_node_type" {
  description = "ElastiCache node type for each Redis node."
  type        = string
  default     = "cache.r6g.large"
}

variable "cache_auth_token" {
  description = "Redis AUTH token (16-128 supported characters). Supply through a secure input mechanism."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.cache_auth_token) >= 16 && length(var.cache_auth_token) <= 128
    error_message = "cache_auth_token must be between 16 and 128 characters."
  }
}

variable "cache_auth_token_version" {
  description = "Increment this value whenever rotating cache_auth_token."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
