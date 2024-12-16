module "networking" {
  source = "./modules/networking"

  vpc_name            = "${var.project}-${var.environment}-vpc"
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  private_subnet_cidrs = local.private_subnet_cidrs
  public_subnet_cidrs  = local.public_subnet_cidrs
  enable_nat_gateway   = true  
  single_nat_gateway   = false 
  enable_vpn_gateway   = false 
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                = var.tags
  aws_region          = var.aws_region
  aws_profile         = var.aws_profile
  environment         = var.environment
  project             = var.project
}

# Security module
module "security" {
  source = "./modules/security"
  
  vpc_id                  = module.networking.vpc_id
  enable_guard_duty       = var.enable_guard_duty
  enable_security_hub     = var.enable_security_hub
  enable_config           = var.enable_config
  enable_cloudtrail       = var.enable_cloudtrail
  log_retention_days      = var.log_retention_days
  kms_key_deletion_window = 30
  enable_flow_logs        = var.enable_logging
  environment            = var.environment
  project                = var.project
  tags                   = var.tags
}

# Database module
module "database" {
  source = "./modules/database"
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  environment           = var.environment
  tags                  = var.tags
  postgres_database_name = var.postgres_database_name
  project                = var.project
}

# Compute module
module "compute" {
  source = "./modules/compute"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  cluster_name       = local.cluster_name    # Add this
  environment        = var.environment
  tags              = var.tags
  container_insights = var.container_insights
  project            = var.project
}