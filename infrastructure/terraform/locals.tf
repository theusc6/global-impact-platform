# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  # AWS Account Information
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition

  # Common name prefix for resources
  name_prefix = "${var.project}-${var.environment}"

  # Common tags for all resources
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })

  # Computed CIDR blocks for subnets
  public_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 0),
    cidrsubnet(var.vpc_cidr, 8, 1)
  ]

  private_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 10),
    cidrsubnet(var.vpc_cidr, 8, 11)
  ]

  # Resource naming
  cluster_name     = "${local.name_prefix}-cluster"
  alb_name         = "${local.name_prefix}-alb"
  rds_identifier   = "${local.name_prefix}-db"
  redis_identifier = "${local.name_prefix}-redis"

  # Security settings
  enable_deletion_protection = var.environment == "prod" ? true : false
  backup_retention_period   = var.environment == "prod" ? 30 : 7

  # Scaling settings
  min_capacity = var.environment == "prod" ? 2 : 1
  max_capacity = var.environment == "prod" ? 10 : 4
}