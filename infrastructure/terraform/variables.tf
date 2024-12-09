# Project Variables
variable "project" {
  description = "Project name"
  type        = string
  default     = "global-impact"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "default"
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

# Security Variables
variable "enable_guard_duty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable Security Hub"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption for applicable resources"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging for applicable resources"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Days to retain logs in CloudWatch"
  type        = number
  default     = 90
}

# Database Variables
variable "multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

# Compute Variables
variable "container_insights" {
  description = "Enable Container Insights for ECS"
  type        = bool
  default     = true
}

# Tags
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project   = "Global Impact Platform"
    ManagedBy = "Terraform"
  }
}

# Database Variables
variable "postgres_database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "globalimpact"  # or whatever default name you want
}