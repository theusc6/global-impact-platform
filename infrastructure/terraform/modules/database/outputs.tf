output "postgres_endpoint" {
  description = "PostgreSQL instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "postgres_port" {
  description = "PostgreSQL instance port"
  value       = aws_db_instance.postgres.port
}

output "postgres_database_name" {
  description = "PostgreSQL database name"
  value       = aws_db_instance.postgres.db_name
}

output "postgres_username" {
  description = "PostgreSQL master username"
  value       = aws_db_instance.postgres.username
  sensitive   = true
}

output "postgres_password_secret_arn" {
  description = "ARN of the secret containing PostgreSQL password"
  value       = aws_secretsmanager_secret.postgres_password.arn
}

output "postgres_security_group_id" {
  description = "ID of PostgreSQL security group"
  value       = aws_security_group.postgres.id
}

output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis cluster port"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].port
}

output "redis_security_group_id" {
  description = "ID of Redis security group"
  value       = aws_security_group.redis.id
}

output "kms_key_id" {
  description = "ID of KMS key used for encryption"
  value       = aws_kms_key.database.key_id
}

output "kms_key_arn" {
  description = "ARN of KMS key used for encryption"
  value       = aws_kms_key.database.arn
}

output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = aws_backup_vault.database.arn
}

output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = aws_backup_vault.database.name
}

output "monitoring_role_arn" {
  description = "ARN of the enhanced monitoring IAM role"
  value       = var.enable_enhanced_monitoring ? aws_iam_role.rds_monitoring[0].arn : null
}

output "parameter_group_postgres" {
  description = "Name of PostgreSQL parameter group"
  value       = aws_db_parameter_group.postgres.name
}

output "parameter_group_redis" {
  description = "Name of Redis parameter group"
  value       = aws_elasticache_parameter_group.redis.name
}