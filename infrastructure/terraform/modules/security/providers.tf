terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region        # Use a variable for region
  profile = var.aws_profile       # Use an AWS profile, if needed
}