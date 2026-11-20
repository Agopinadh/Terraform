
# API Gateway URL
output "api_url" {
  description = "API Gateway health endpoint URL"
  value       = "${aws_apigatewayv2_api.http.api_endpoint}/health"
}

# VPC ID
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

# Private subnet IDs
output "private_subnet_ids" {
  description = "IDs of the two private subnets"
  value       = aws_subnet.private[*].id
}

# Availability Zones
output "availability_zones" {
  description = "Availability Zones used by the subnets"
  value       = local.azs
}

# RDS MySQL endpoint
output "rds_address" {
  description = "MySQL RDS endpoint address"
  value       = aws_db_instance.main.address
}

# RDS MySQL port
output "rds_port" {
  description = "MySQL database port"
  value       = aws_db_instance.main.port
}

# RDS database name
output "rds_database_name" {
  description = "MySQL database name"
  value       = aws_db_instance.main.db_name
}

# RDS secret ARN
output "rds_secret_arn" {
  description = "Secrets Manager ARN containing database credentials"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

# Lambda function name
output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.api.function_name
}

# Lambda function ARN
output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.api.arn
}

# API Gateway ID
output "api_gateway_id" {
  description = "HTTP API Gateway ID"
  value       = aws_apigatewayv2_api.http.id
}

# Security group IDs
output "security_group_ids" {
  description = "Security groups created for the application"
  value = {
    lambda    = aws_security_group.lambda.id
    database  = aws_security_group.db.id
    endpoints = aws_security_group.endpoints.id
  }
}

# VPC endpoint IDs
output "vpc_endpoint_ids" {
  description = "VPC endpoint IDs"
  value = {
    secretsmanager = aws_vpc_endpoint.secretsmanager.id
    logs            = aws_vpc_endpoint.logs.id
  }
}
