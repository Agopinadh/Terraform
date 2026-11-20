# variable "team" {
#   type    = bool
#   default = false
# }


##################second condition#############3
# variable "aws_region" {
#     description = "The region in which to create the infrastructure"
#     type = string
#     nullable = false
#     validation {
#       condition = var.aws_region == "us-east-1" || var.aws_region == "ap-south-1"
#       error_message = "The aws_region must be us-east-1 or us-west-1."
#     }

# }


#########condition 3###########
variable "environment" {
  type    = string
  default = "prod"

}