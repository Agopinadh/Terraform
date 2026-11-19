variable "bucket" {
  default     = ""
  description = "Name of S3 bucket to create"
  type        = string
}

variable "acl" {
  default     = "private"
  description = "Access control list for the S3 bucket"
  type        = string
}

variable "control_object_ownership" {
  default     = true
  description = "Whether to control object ownership for the S3 bucket"
  type        = bool
}

variable "object_ownership" {
  default     = "ObjectWriter"
  description = "Object ownership setting for the S3 bucket"
  type        = string
}

variable "versioning" {
  default = {
    enabled = true
  }

  description = "Versioning configuration of the S3 bucket"
  type = object({
    enabled = bool
  })
}