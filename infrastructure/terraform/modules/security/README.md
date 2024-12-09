# Security Module

This module manages security configurations and resources for the Global Impact Platform.

## Features

### Core Security Services
* GuardDuty threat detection
* Security Hub with CIS and PCI DSS standards
* AWS Config configuration recorder
* CloudTrail logging and monitoring
* IAM password policies

### Encryption & Key Management
* KMS key management for encryption
* Key rotation policies
* Encrypted CloudTrail logs
* Encrypted CloudWatch logs

### Logging & Monitoring
* CloudTrail multi-region logging
* CloudWatch log groups
* S3 bucket for audit logs
* AWS Config recording

### Identity & Access Management
* IAM password policy enforcement
* IAM roles for services
* Secure policy documents
* Principle of least privilege

## Usage

```hcl
module "security" {
  source = "./modules/security"
  
  vpc_id                  = module.networking.vpc_id
  enable_guard_duty       = true
  enable_security_hub     = true
  enable_config           = true
  enable_cloudtrail       = true
  log_retention_days      = 90
  kms_key_deletion_window = 30
  enable_flow_logs        = true
  environment            = "dev"
  project                = "global-impact"
  tags                   = {
    Environment = "dev"
    Project     = "Global Impact Platform"
  }
}
```

## Required Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| vpc_id | VPC ID for security resources | string | yes |
| environment | Environment name | string | yes |
| project | Project name | string | yes |

## Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enable_guard_duty | Enable GuardDuty | bool | true |
| enable_security_hub | Enable Security Hub | bool | true |
| enable_config | Enable AWS Config | bool | true |
| enable_cloudtrail | Enable CloudTrail | bool | true |
| log_retention_days | Days to retain logs in CloudWatch | number | 90 |
| kms_key_deletion_window | Waiting period for KMS key deletion | number | 30 |
| enable_flow_logs | Enable VPC Flow Logs | bool | true |
| tags | Tags to apply to resources | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| kms_key_arn | ARN of the KMS key |
| kms_key_id | ID of the KMS key |
| guardduty_detector_id | ID of the GuardDuty detector |
| security_hub_arn | ARN of the Security Hub |
| cloudtrail_arn | ARN of the CloudTrail |
| cloudtrail_bucket_name | Name of the CloudTrail S3 bucket |
| cloudtrail_log_group_name | Name of the CloudTrail CloudWatch log group |
| config_recorder_id | ID of the AWS Config recorder |

## Resources Created

### KMS & Encryption
* KMS key for encryption
* KMS key alias

### GuardDuty
* GuardDuty detector with S3 logs monitoring

### Security Hub
* Security Hub account configuration
* CIS AWS Foundations Benchmark standards
* PCI DSS standards

### CloudTrail
* Multi-region trail configuration
* S3 bucket for logs
* CloudWatch log group
* IAM roles and policies for CloudTrail

### AWS Config
* Configuration recorder
* Recording status
* IAM role for Config

### IAM & Policies
* Password policy
* Service roles
* KMS policies
* S3 bucket policies

## Security Best Practices Implemented

1. **Encryption**
   * KMS key rotation enabled
   * Encrypted CloudTrail logs
   * Encrypted CloudWatch logs

2. **Logging & Monitoring**
   * Multi-region CloudTrail
   * GuardDuty enabled
   * AWS Config recording

3. **Identity & Access**
   * Strong password policy
   * Principle of least privilege
   * Service-specific roles

4. **Compliance**
   * CIS Benchmark standards
   * PCI DSS compliance
   * AWS Config rules

## Notes

* The module requires a pre-existing VPC
* All resources are tagged with environment and project tags
* KMS key deletion window is configurable but defaults to 30 days
* Log retention periods are configurable but default to 90 days