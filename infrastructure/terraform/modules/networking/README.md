# Networking Module

This module sets up the core networking infrastructure for the Global Impact Platform.

## Features

- VPC with public and private subnets
- Internet Gateway for public subnets
- NAT Gateways for private subnet internet access
- Route tables and associations
- Network ACLs
- VPC Endpoints for AWS services

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  environment         = "dev"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b"]
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, prod) | string | n/a | yes |
| vpc_cidr | CIDR block for VPC | string | n/a | yes |
| availability_zones | List of AZs | list(string) | n/a | yes |
| public_subnet_cidrs | List of public subnet CIDRs | list(string) | n/a | yes |
| private_subnet_cidrs | List of private subnet CIDRs | list(string) | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the created VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| nat_gateway_ips | List of NAT Gateway IPs |

## Security Considerations

- All private subnets are isolated from direct internet access
- NAT Gateways provide controlled outbound internet access
- Network ACLs provide subnet-level security
- VPC Flow Logs can be enabled for network monitoring
- Security groups should be configured at the service level