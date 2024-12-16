data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name_prefix = "${var.project}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

# KMS Key for encryption
resource "aws_kms_key" "security" {
  description             = "KMS key for security services encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true
  policy                 = data.aws_iam_policy_document.kms_policy.json

  tags = local.common_tags
}

resource "aws_kms_alias" "security" {
  name          = "alias/${local.name_prefix}-security-key"
  target_key_id = aws_kms_key.security.key_id
}

# GuardDuty
resource "aws_guardduty_detector" "main" {
  count = var.enable_guard_duty ? 1 : 0

  enable = true
  
  datasources {
    s3_logs {
      enable = true
    }
  }

  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = local.common_tags
}

# Security Hub
resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0

  enable_default_standards = true
  control_finding_generator = "SECURITY_CONTROL"
  auto_enable_controls = true
}

# Enable Security Hub standards
resource "aws_securityhub_standards_subscription" "cis" {
  count = var.enable_security_hub ? 1 : 0

  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${local.region}::standards/cis-aws-foundations-benchmark/v1.4.0"
}

resource "aws_securityhub_standards_subscription" "pci" {
  count = var.enable_security_hub ? 1 : 0

  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${local.region}::standards/pci-dss/v3.2.1"
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${local.name_prefix}-audit-trail"
  s3_bucket_name               = aws_s3_bucket.cloudtrail[0].id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  kms_key_id                   = aws_kms_key.security.arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail[0].arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  tags = local.common_tags
}

# CloudTrail S3 Bucket
resource "aws_s3_bucket" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = "${local.name_prefix}-cloudtrail-logs-${local.account_id}"
  
  force_destroy = true

  tags = local.common_tags
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy[0].json
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = var.enable_cloudtrail ? 1 : 0
  name              = "/aws/cloudtrail/${local.name_prefix}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.security.arn

  tags = local.common_tags
}

# AWS Config
resource "aws_config_configuration_recorder" "main" {
  count = var.enable_config ? 1 : 0

  name     = "${local.name_prefix}-config-recorder"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported = true
  }
}

resource "aws_config_configuration_recorder_status" "main" {
  count = var.enable_config ? 1 : 0

  name       = aws_config_configuration_recorder.main[0].name
  is_enabled = true
  depends_on = [aws_config_configuration_recorder.main]
}

# IAM Password Policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers               = true
  require_uppercase_characters   = true
  require_symbols               = true
  allow_users_to_change_password = true
  max_password_age              = 90
  password_reuse_prevention     = 24
}

# Policy Documents
data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
    actions = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow Config to encrypt logs"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  count = var.enable_cloudtrail ? 1 : 0

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail[0].arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail[0].arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

# IAM Roles
resource "aws_iam_role" "config" {
  count = var.enable_config ? 1 : 0
  name  = "${local.name_prefix}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
  ]

  tags = local.common_tags
}

resource "aws_iam_role" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0
  name  = "${local.name_prefix}-cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  count = var.enable_cloudtrail ? 1 : 0
  name  = "${local.name_prefix}-cloudtrail-cloudwatch-policy"
  role  = aws_iam_role.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
      }
    ]
  })
}