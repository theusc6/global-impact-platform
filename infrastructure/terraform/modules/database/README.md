# Database Module

This module manages the database infrastructure for the Global Impact Platform.

## Features

- RDS PostgreSQL instances
- Redis clusters for caching
- Backup configurations
- Multi-AZ deployment options
- Automated snapshots
- Parameter groups
- Subnet groups
- Monitoring and alerting

## Usage

```hcl
module "database" {
  source = "../../modules/database"

  environment = "dev"
  vpc_id      = module.networking.vpc_id
  subnet_ids  = module.networking.private_subnet_ids

  rds_instance_class    = "db.t3.medium"
  redis_instance_type   = "cache.t3.micro"
  multi_az             = false
  backup_retention     = 7
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | string | n/a | yes |
| vpc_id | VPC ID | string | n/a | yes |
| subnet_ids | Private subnet IDs | list(string) | n/a | yes |
| rds_instance_class | RDS instance type | string | db.t3.medium | no |
| redis_instance_type | Redis node type | string | cache.t3.micro | no |
| multi_az | Enable Multi-AZ deployment | bool | false | no |
| backup_retention | Backup retention period in days | number | 7 | no |

## Outputs

| Name | Description |
|------|-------------|
| rds_endpoint | RDS instance endpoint |
| redis_endpoint | Redis primary endpoint |
| rds_security_group_id | Security group ID for RDS |
| redis_security_group_id | Security group ID for Redis |

## Security Considerations

- All databases in private subnets
- Encryption at rest enabled
- SSL/TLS for data in transit
- Automated password rotation
- Regular automated backups
- Performance insights enabled
- Enhanced monitoring