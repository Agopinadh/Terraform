resource "aws_kms_key" "main" {
  description             = "Encryption key for ${var.name} data"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = {
    Name = "${var.name}-kms"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.main.key_id
}

resource "random_id" "bucket" {
  byte_length = 4
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.name}-assets-${random_id.bucket.hex}"

  tags = {
    Name = "${var.name}-assets"
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.assets.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.assets.arn,
        "${aws_s3_bucket.assets.arn}/*"
      ]
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      }
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.assets]
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-db"
  subnet_ids = aws_subnet.data[*].id

  tags = {
    Name = "${var.name}-db"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.name}-db"
  description = "MySQL access from application instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-db"
  }
}

resource "aws_db_instance" "primary" {
  identifier                    = "${var.name}-primary"
  engine                        = "mysql"
  instance_class                = var.db_instance_class
  allocated_storage             = 20
  max_allocated_storage         = 100
  storage_type                  = "gp3"
  storage_encrypted             = true
  kms_key_id                    = aws_kms_key.main.arn
  db_name                       = "appdb"
  username                      = "appadmin"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.main.arn
  db_subnet_group_name          = aws_db_subnet_group.main.name
  vpc_security_group_ids        = [aws_security_group.database.id]
  multi_az                      = true
  publicly_accessible           = false
  backup_retention_period       = 7
  deletion_protection           = var.deletion_protection
  skip_final_snapshot           = false
  final_snapshot_identifier     = "${var.name}-final-${random_id.snapshot.hex}"
  auto_minor_version_upgrade    = true

  tags = {
    Name = "${var.name}-primary"
    Role = "primary"
  }
}

resource "random_id" "snapshot" {
  byte_length = 4
}

resource "aws_db_instance" "read_replica" {
  identifier                = "${var.name}-read-replica"
  replicate_source_db       = aws_db_instance.primary.identifier
  instance_class            = var.db_instance_class
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [aws_security_group.database.id]
  publicly_accessible       = false
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name}-replica-final-${random_id.snapshot.hex}"
  deletion_protection       = var.deletion_protection

  tags = {
    Name = "${var.name}-read-replica"
    Role = "read-replica"
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name}-cache"
  subnet_ids = aws_subnet.data[*].id
}

resource "aws_security_group" "cache" {
  name        = "${var.name}-cache"
  description = "Redis access from application instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis from app tier"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-cache"
  }
}

resource "random_password" "redis_auth" {
  length  = 32
  special = false
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.name}-redis"
  description                = "Redis cache for ${var.name}"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = var.redis_node_type
  port                       = 6379
  parameter_group_name       = "default.redis7"
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.cache.id]
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = aws_kms_key.main.arn
  auth_token                 = random_password.redis_auth.result

  tags = {
    Name = "${var.name}-redis"
  }
}
