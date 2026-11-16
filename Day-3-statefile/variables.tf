variable "ami_id" {
  type        = string
  description = "The AMI ID to use for the instance"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "The type of instance to create"
  default     = ""
}

variable "name" {
  type        = string
  description = "The name of the instance"
  default     = ""
}