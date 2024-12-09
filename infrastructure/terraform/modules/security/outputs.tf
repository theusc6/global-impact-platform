output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.security.arn
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.security.key_id
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = var.enable_guard_duty ? aws_guardduty_detector.main[0].id : null
}

output "security_hub_arn" {
  description = "ARN of the Security Hub"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].id : null
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudtrail_bucket_name" {
  description = "Name of the CloudTrail S3 bucket"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].id : null
}

output "cloudtrail_log_group_name" {
  description = "Name of the CloudTrail CloudWatch log group"
  value       = var.enable_cloudtrail ? aws_cloudwatch_log_group.cloudtrail[0].name : null
}

output "config_recorder_id" {
  description = "ID of the AWS Config recorder"
  value       = var.enable_config ? aws_config_configuration_recorder.main[0].id : null
}