output "vpc_id" {
  description = "ID of the private VPC."
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "application_security_group_id" {
  description = "Attach this security group to application workloads that need database and cache access."
  value       = aws_security_group.application.id
}

output "mysql_writer_endpoint" {
  description = "MySQL primary endpoint."
  value       = aws_db_instance.primary.address
}

output "mysql_reader_endpoint" {
  description = "MySQL read replica endpoint."
  value       = aws_db_instance.read_replica.address
}

output "mysql_master_secret_arn" {
  description = "Secrets Manager ARN containing the RDS-managed master credentials."
  value       = aws_db_instance.primary.master_user_secret[0].secret_arn
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint; clients must use TLS and AUTH."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint for distributing read traffic."
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}
