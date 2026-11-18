
variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = null
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = ""
}
