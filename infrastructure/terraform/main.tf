# Root main.tf

# Networking module needs to be first since other modules depend on VPC
module "networking" {
  source = "./modules/networking"

  environment         = var.environment
  project            = var.project
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags              = var.tags
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
  
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  environment         = var.environment
  project             = var.project
  tags               = var.tags
  kms_key_id         = module.security.kms_key_id
  multi_az           = var.multi_az
  postgres_database_name = var.postgres_database_name  # Add this line
}

# Compute module
module "compute" {
  source = "./modules/compute"
  
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  public_subnet_ids    = module.networking.public_subnet_ids
  environment         = var.environment
  project             = var.project
  tags               = var.tags
  container_insights  = var.container_insights
}