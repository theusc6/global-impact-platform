variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for databases"
  type        = list(string)
}

# PostgreSQL Variables
variable "postgres_instance_class" {
  description = "Instance class for PostgreSQL"
  type        = string
  default     = "db.t3.medium"
}

variable "postgres_allocated_storage" {
  description = "Allocated storage for PostgreSQL in GB"
  type        = number
  default     = 20
}

variable "postgres_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "14.7"
}

variable "postgres_database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
}

variable "postgres_multi_az" {
  description = "Enable Multi-AZ deployment for PostgreSQL"
  type        = bool
  default     = false
}

variable "postgres_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

# Enhanced Security Variables
variable "enable_ssl_enforcement" {
  description = "Enforce SSL connections to databases"
  type        = bool
  default     = true
}

variable "enable_secret_rotation" {
  description = "Enable automatic rotation of database secrets"
  type        = bool
  default     = true
}

variable "secret_rotation_days" {
  description = "Number of days between secret rotations"
  type        = number
  default     = 30
}

variable "enable_enhanced_monitoring" {
  description = "Enable enhanced monitoring for RDS"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds"
  type        = number
  default     = 30
}

variable "enable_log_exports" {
  description = "Enable log exports to CloudWatch Logs"
  type        = bool
  default     = true
}

variable "enable_guard_duty" {
  description = "Enable GuardDuty monitoring"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window" {
  description = "Deletion window for KMS keys in days"
  type        = number
  default     = 30
}

variable "enable_backup_encryption" {
  description = "Enable encryption for backups"
  type        = bool
  default     = true
}

# Redis Variables
variable "redis_node_type" {
  description = "Node type for Redis cluster"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_nodes" {
  description = "Number of cache nodes in the cluster"
  type        = number
  default     = 1
}

variable "redis_parameter_group_family" {
  description = "Redis parameter group family"
  type        = string
  default     = "redis7"
}

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

# Network Security Variables
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the databases"
  type        = list(string)
  default     = []
}

variable "enable_network_isolation" {
  description = "Enable strict network isolation for databases"
  type        = bool
  default     = true
}

# Audit and Monitoring
variable "enable_audit_logging" {
  description = "Enable audit logging for databases"
  type        = bool
  default     = true
}

variable "audit_log_retention_days" {
  description = "Number of days to retain audit logs"
  type        = number
  default     = 90
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights for PostgreSQL"
  type        = bool
  default     = true
}

variable "performance_insights_retention_days" {
  description = "Number of days to retain Performance Insights data"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "default"
}

variable "project" {
  description = "Project name"
  type        = string
}