# resource "aws_instance" "name" {
#   ami           = "ami-06f98347e4f9c7328"
#   instance_type = "t3.micro"
#   count         = var.team ? 1 : 0
#   # if dev is true then create 1 instance if false then create 0 instance.
#   # true 1
#   # false 0

# }


#################second condition###################
# resource "aws_s3_bucket" "name" {
#     bucket = "joburg-terraform-123"

# }

#######################condition3####################
resource "aws_instance" "example" {
  count         = var.environment == "prod" ? 3 : 1
  ami           = "ami-06f98347e4f9c7328"
  instance_type = "t3.micro"
  tags = {
    Name = "example-${count.index}"
  }

}