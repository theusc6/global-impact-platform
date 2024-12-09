# Data source for current region
data "aws_region" "current" {}

# KMS Key for database encryption
resource "aws_kms_key" "database" {
  description             = "KMS key for database encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-database-kms"
    }
  )
}

resource "aws_kms_alias" "database" {
  name          = "alias/${var.environment}-database-key"
  target_key_id = aws_kms_key.database.key_id
}

# Random password generation for PostgreSQL
resource "random_password" "postgres" {
  length      = 32
  special     = true
  min_special = 2
  min_numeric = 2
  min_upper   = 2
  min_lower   = 2
}

# Store PostgreSQL password in Secrets Manager
resource "aws_secretsmanager_secret" "postgres_password" {
  name        = "${var.environment}-postgres-password"
  description = "PostgreSQL master password"
  kms_key_id  = aws_kms_key.database.arn
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "postgres_password" {
  secret_id     = aws_secretsmanager_secret.postgres_password.id
  secret_string = jsonencode({
    username = "postgresadmin"
    password = random_password.postgres.result
    engine   = "postgres"
    port     = 5432
  })
}

# IAM role for the Lambda function
resource "aws_iam_role" "secret_rotation_lambda" {
  count = var.enable_secret_rotation ? 1 : 0
  name  = "${var.environment}-secret-rotation-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for the Lambda function
resource "aws_iam_role_policy" "secret_rotation_lambda" {
  count = var.enable_secret_rotation ? 1 : 0
  name  = "${var.environment}-secret-rotation-policy"
  role  = aws_iam_role.secret_rotation_lambda[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = [aws_secretsmanager_secret.postgres_password.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "rds:ModifyDBInstance",
          "rds:DescribeDBInstances"
        ]
        Resource = [aws_db_instance.postgres.arn]
      }
    ]
  })
}

# Lambda function for secret rotation
resource "aws_lambda_function" "secret_rotation" {
  count         = var.enable_secret_rotation ? 1 : 0
  filename      = "${path.module}/lambda/rotation.zip"
  function_name = "${var.environment}-secret-rotation"
  role          = aws_iam_role.secret_rotation_lambda[0].arn
  handler       = "rotation.handler"  # Changed from index.handler
  runtime       = "python3.9"        # Changed from nodejs18.x

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }

  tags = var.tags
}

# Secret rotation configuration
resource "aws_secretsmanager_secret_rotation" "postgres" {
  count               = var.enable_secret_rotation ? 1 : 0
  secret_id           = aws_secretsmanager_secret.postgres_password.id
  rotation_lambda_arn = aws_lambda_function.secret_rotation[0].arn

  rotation_rules {
    automatically_after_days = var.secret_rotation_days
  }
}

# PostgreSQL Parameter Group with enhanced security
resource "aws_db_parameter_group" "postgres" {
  family = "postgres14"
  name   = "${var.environment}-postgres-params"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "rds.force_ssl"
    value = var.enable_ssl_enforcement ? "1" : "0"
  }

  parameter {
    name  = "ssl"
    value = var.enable_ssl_enforcement ? "1" : "0"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  parameter {
    name  = "password_encryption"
    value = "scram-sha-256"
  }

  tags = var.tags
}

# Enhanced PostgreSQL Security Group
resource "aws_security_group" "postgres" {
  name_prefix = "${var.environment}-postgres-"
  vpc_id      = var.vpc_id
  description = "Security group for PostgreSQL database"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_cidr_blocks
    description     = "PostgreSQL access from allowed security groups"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-postgres-sg"
    }
  )
}

# PostgreSQL Instance with enhanced security
resource "aws_db_instance" "postgres" {
  identifier = "${var.environment}-postgres"

  engine         = "postgres"
  engine_version = var.postgres_engine_version
  instance_class = var.postgres_instance_class

  allocated_storage     = var.postgres_allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true
  kms_key_id          = aws_kms_key.database.arn

  db_name  = var.postgres_database_name
  username = jsondecode(aws_secretsmanager_secret_version.postgres_password.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.postgres_password.secret_string)["password"]

  multi_az               = var.postgres_multi_az
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name

  backup_retention_period = var.postgres_backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.performance_insights_retention_days
  performance_insights_kms_key_id      = aws_kms_key.database.arn

  monitoring_interval = var.enable_enhanced_monitoring ? var.monitoring_interval : 0
  monitoring_role_arn = var.enable_enhanced_monitoring ? aws_iam_role.rds_monitoring[0].arn : null

  enabled_cloudwatch_logs_exports = var.enable_log_exports ? ["postgresql", "upgrade"] : []

  deletion_protection = true
  skip_final_snapshot = false
  
  copy_tags_to_snapshot = true
  
  auto_minor_version_upgrade = true

  tags = var.tags
}

# Redis Parameter Group with enhanced security
resource "aws_elasticache_parameter_group" "redis" {
  family = var.redis_parameter_group_family
  name   = "${var.environment}-redis-params"

  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "AKE"
  }

  tags = var.tags
}

# Enhanced Redis Security Group
resource "aws_security_group" "redis" {
  name_prefix = "${var.environment}-redis-"
  vpc_id      = var.vpc_id
  description = "Security group for Redis cluster"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.allowed_cidr_blocks
    description     = "Redis access from allowed security groups"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-redis-sg"
    }
  )
}

# Redis Cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.environment}-redis"
  engine              = "redis"
  node_type           = var.redis_node_type
  num_cache_nodes     = var.redis_num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  port                = 6379
  security_group_ids  = [aws_security_group.redis.id]
  subnet_group_name   = aws_elasticache_subnet_group.redis.name

  engine_version    = var.redis_engine_version
  apply_immediately = false

  snapshot_retention_limit = var.environment == "prod" ? 7 : 1
  snapshot_window         = "03:00-04:00"
  maintenance_window      = "sun:05:00-sun:06:00"

  tags = var.tags
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${var.environment}-database-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "Database CPU utilization is too high"
  alarm_actions      = []  # Add SNS topic ARN for notifications

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.id
  }
}

# Enhanced Monitoring IAM Role
resource "aws_iam_role" "rds_monitoring" {
  count = var.enable_enhanced_monitoring ? 1 : 0
  name  = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.enable_enhanced_monitoring ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Subnet Groups
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.environment}-postgres-subnet"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-redis-subnet"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

# Backup Vault for additional backup storage
resource "aws_backup_vault" "database" {
  name        = "${var.environment}-database-backup-vault"
  kms_key_arn = aws_kms_key.database.arn
  tags        = var.tags
}

# AWS Backup Plan
resource "aws_backup_plan" "database" {
  name = "${var.environment}-database-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.database.name
    schedule          = "cron(0 5 ? * * *)"

    lifecycle {
      delete_after = 30
    }
  }

  tags = var.tags
}