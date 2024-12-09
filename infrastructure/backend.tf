terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # These will need to be configured during terraform init
    # bucket         = "your-terraform-state-bucket"
    # key            = "global-impact/terraform.tfstate"
    # region         = "us-west-2"
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true
  }
}

provider "aws" {
  # Default region, can be overridden in environment configurations
  region = "us-west-2"

  default_tags {
    tags = {
      Project     = "Global Impact Platform"
      Environment = terraform.workspace
      ManagedBy   = "Terraform"
    }
  }
}