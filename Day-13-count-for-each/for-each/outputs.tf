output "instance_ids" {
  description = "EC2 instance IDs"
  value = {
    for name, instance in aws_instance.name :
    name => instance.id
  }
}

output "instance_names" {
  description = "EC2 instance names"
  value = {
    for name, instance in aws_instance.name :
    name => instance.tags.Name
  }
}

output "private_ips" {
  description = "Private IP addresses"
  value = {
    for name, instance in aws_instance.name :
    name => instance.private_ip
  }
}
