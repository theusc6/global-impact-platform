# Infrastructure

This directory contains the Infrastructure as Code (IaC) for the Global Impact Platform using Terraform.

## Structure

```
infrastructure/
├── terraform/
│   ├── environments/      # Environment-specific configurations
│   │   ├── dev/          # Development environment
│   │   └── prod/         # Production environment
│   ├── modules/          # Reusable Terraform modules
│   │   ├── networking/   # VPC, subnets, routing
│   │   ├── compute/      # ECS, EC2, containers
│   │   ├── database/     # RDS, Redis
│   │   └── security/     # IAM, security groups
│   └── backend.tf        # S3 backend configuration
```

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Access to AWS account with necessary permissions

## Usage

1. Set up AWS credentials:
```bash
aws configure
```

2. Initialize Terraform:
```bash
cd terraform/environments/dev
terraform init
```

3. Plan changes:
```bash
terraform plan -out=tfplan
```

4. Apply changes:
```bash
terraform apply tfplan
```

## Modules

### Networking
- VPC configuration
- Public/private subnets
- NAT gateways
- Route tables

### Compute
- ECS cluster
- Load balancers
- Auto-scaling groups

### Database
- RDS instances
- Redis clusters
- Backup configurations

### Security
- IAM roles and policies
- Security groups
- KMS keys
- WAF configuration

## Environments

### Development
- Lower-cost configurations
- Minimal redundancy
- Debugging enabled

### Production
- High availability
- Multi-AZ deployment
- Enhanced security

## Backend

The Terraform state is stored in an S3 bucket with the following configuration:
- Bucket: [Your S3 Bucket Name]
- Region: [Your Region]
- DynamoDB Table for State Locking

## Security Considerations

- All resources are deployed within a VPC
- Private subnets for sensitive resources
- Security groups limit access
- Encryption at rest enabled
- SSL/TLS for data in transit