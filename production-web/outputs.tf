output "cloudfront_url" {
  description = "CloudFront distribution URL."
  value       = "https://${aws_cloudfront_distribution.application.domain_name}"
}

output "application_load_balancer_dns" {
  description = "ALB DNS name; protected by AWS WAF."
  value       = aws_lb.application.dns_name
}

output "internal_network_load_balancer_dns" {
  description = "Private NLB DNS name, reachable only within the VPC."
  value       = aws_lb.network.dns_name
}

output "api_url" {
  description = "API Gateway HTTP API endpoint."
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "vpc_id" {
  description = "Application VPC ID."
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Public, application, and data subnet IDs."
  value = {
    public = aws_subnet.public[*].id
    app    = aws_subnet.app[*].id
    data   = aws_subnet.data[*].id
  }
}

output "assets_bucket_name" {
  description = "Private, versioned, KMS-encrypted S3 bucket."
  value       = aws_s3_bucket.assets.bucket
}

output "rds_primary_endpoint" {
  description = "RDS MySQL primary endpoint."
  value       = aws_db_instance.primary.endpoint
}

output "rds_read_replica_endpoint" {
  description = "RDS MySQL read replica endpoint."
  value       = aws_db_instance.read_replica.endpoint
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN for the RDS-managed master credentials."
  value       = aws_db_instance.primary.master_user_secret[0].secret_arn
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint; the auth token remains in Terraform state."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "transit_gateway_id" {
  description = "Transit Gateway ID, or null when it is disabled."
  value       = var.enable_transit_gateway ? aws_ec2_transit_gateway.main[0].id : null
}

output "direct_peer_connection_id" {
  description = "Direct VPC peering connection ID, or null when not configured."
  value       = var.peer_vpc_id != "" ? aws_vpc_peering_connection.peer[0].id : null
}
