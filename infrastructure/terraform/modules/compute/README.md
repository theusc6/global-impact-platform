# Compute Module

This module manages the compute resources for the Global Impact Platform.

## Features

### Core Compute Services
* ECS Cluster configuration with Container Insights
* Application Load Balancer (ALB)
* Auto Scaling capabilities
* WAF integration
* Shield protection (optional)

### Load Balancing
* Application Load Balancer
* Target Groups
* HTTP/HTTPS listeners
* SSL/TLS support
* Access logging

### Security
* WAF protection
* Security groups
* HTTPS redirection
* IP rate limiting
* Shield Advanced protection (optional)

### Auto Scaling
* CPU-based auto scaling
* Memory-based auto scaling
* Configurable capacity limits
* Target tracking policies

## Usage

```hcl
module "compute" {
  source = "./modules/compute"
  
  cluster_name        = "my-cluster"
  environment         = "dev"
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  public_subnet_ids   = module.networking.public_subnet_ids
  container_insights  = true
  enable_waf         = true
  certificate_arn    = "arn:aws:acm:region:account:certificate/xxx"
  
  tags = {
    Environment = "dev"
    Project     = "Global Impact Platform"
  }
}
```

## Required Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| cluster_name | Name of the ECS cluster | string | yes |
| vpc_id | ID of the VPC | string | yes |
| private_subnet_ids | List of private subnet IDs for ECS tasks | list(string) | yes |
| public_subnet_ids | List of public subnet IDs for ALB | list(string) | yes |
| environment | Environment name | string | yes |

## Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| container_insights | Enable CloudWatch Container Insights | bool | true |
| enable_waf | Enable WAF for ALB | bool | true |
| waf_ip_rate_limit | Number of requests allowed from an IP in 5 minutes | number | 2000 |
| certificate_arn | ARN of ACM certificate for HTTPS | string | null |
| enable_shield_protection | Enable AWS Shield Advanced protection | bool | false |
| enable_access_logs | Enable ALB access logs | bool | false |
| access_logs_bucket | S3 bucket for ALB access logs | string | null |
| enable_autoscaling | Enable autoscaling for ECS service | bool | true |
| min_capacity | Minimum number of tasks | number | 1 |
| max_capacity | Maximum number of tasks | number | 4 |
| task_cpu | CPU units for the ECS task | number | 256 |
| task_memory | Memory for the ECS task | number | 512 |
| tags | Tags to apply to resources | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_name | Name of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| execution_role_arn | ARN of the ECS task execution role |
| alb_dns_name | DNS name of the load balancer |
| alb_arn | ARN of the load balancer |
| alb_target_group_arn | ARN of the target group |
| alb_security_group_id | ID of the ALB security group |
| ecs_tasks_security_group_id | ID of the ECS tasks security group |
| autoscaling_target_id | ID of the autoscaling target |

## Resources Created

### ECS Resources
* ECS Cluster
* Task Execution Role
* Task Execution Policy

### Load Balancer Resources
* Application Load Balancer
* Target Group
* HTTP/HTTPS Listeners
* Security Groups

### WAF Resources
* Web ACL
* IP Rate Limiting Rule
* AWS Managed Rules

### Auto Scaling Resources
* Application Auto Scaling Target
* CPU Utilization Policy
* Memory Utilization Policy

## Security Best Practices Implemented

1. **Network Security**
   * ALB in public subnets
   * ECS tasks in private subnets
   * Restricted security group access
   * WAF protection

2. **Access Control**
   * HTTP to HTTPS redirection
   * IP rate limiting
   * Minimal IAM permissions

3. **Monitoring**
   * Container Insights (optional)
   * Access Logging (optional)
   * Health checks

4. **Auto Scaling**
   * CPU-based scaling
   * Memory-based scaling
   * Configurable thresholds

## Notes

* Requires existing VPC with public and private subnets
* HTTPS requires a valid ACM certificate
* WAF configuration includes AWS managed rule sets
* Auto scaling targets 80% utilization for both CPU and memory