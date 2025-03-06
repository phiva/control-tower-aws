# modules/centralized_logging/main.tf

provider "aws" {
  alias  = "log_archive"
  region = var.aws_region
  
  assume_role {
    role_arn = "arn:aws:iam::${var.log_archive_account_id}:role/AWSControlTowerExecution"
  }
}

provider "aws" {
  alias  = "audit"
  region = var.aws_region
  
  assume_role {
    role_arn = "arn:aws:iam::${var.audit_account_id}:role/AWSControlTowerExecution"
  }
}

# Cloudtrail Bucket para logs centralizados
resource "aws_s3_bucket" "cloudtrail" {
  provider = aws.log_archive
  
  bucket = var.cloudtrail_bucket_name
  
  tags = {
    Name        = "Centralized CloudTrail Logs"
    Environment = "Production"
    Function    = "LogStorage"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_lifecycle" {
  provider = aws.log_archive
  
  bucket = aws_s3_bucket.cloudtrail.id
  
  rule {
    id     = "archive-logs"
    status = "Enabled"
    
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    
    expiration {
      days = var.log_retention_period
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  provider = aws.log_archive
  
  bucket = aws_s3_bucket.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:GetBucketAcl",
        Resource  = "arn:aws:s3:::${var.cloudtrail_bucket_name}"
      },
      {
        Sid       = "AWSCloudTrailWrite",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "arn:aws:s3:::${var.cloudtrail_bucket_name}/AWSLogs/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# AWS Config Bucket para registros de configuração
resource "aws_s3_bucket" "config" {
  provider = aws.log_archive
  
  bucket = var.config_bucket_name
  
  tags = {
    Name        = "Centralized Config Logs"
    Environment = "Production"
    Function    = "ConfigStorage"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "config_lifecycle" {
  provider = aws.log_archive
  
  bucket = aws_s3_bucket.config.id
  
  rule {
    id     = "archive-config"
    status = "Enabled"
    
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    
    expiration {
      days = var.log_retention_period
    }
  }
}

resource "aws_s3_bucket_policy" "config_policy" {
  provider = aws.log_archive
  
  bucket = aws_s3_bucket.config.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSConfigBucketPermissionsCheck",
        Effect    = "Allow",
        Principal = { Service = "config.amazonaws.com" },
        Action    = "s3:GetBucketAcl",
        Resource  = "arn:aws:s3:::${var.config_bucket_name}"
      },
      {
        Sid       = "AWSConfigBucketDelivery",
        Effect    = "Allow",
        Principal = { Service = "config.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "arn:aws:s3:::${var.config_bucket_name}/AWSLogs/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudWatch Logs para CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  provider = aws.audit
  
  name              = "/aws/cloudtrail/organization-trail"
  retention_in_days = 365
  
  tags = {
    Name      = "CloudTrail Logs"
    ManagedBy = "Terraform"
  }
}

# Criar Trail Organizacional
resource "aws_cloudtrail" "organization_trail" {
  name                          = "organization-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true
  
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_to_cloudwatch.arn
  
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
  
  depends_on = [
    aws_s3_bucket_policy.cloudtrail_policy
  ]
}

# IAM Role para CloudTrail enviar logs para CloudWatch
resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  provider = aws.audit
  
  name = "CloudTrailToCloudWatchRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_to_cloudwatch" {
  provider = aws.audit
  
  name = "CloudTrailToCloudWatchPolicy"
  role = aws_iam_role.cloudtrail_to_cloudwatch.id
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

# CloudWatch Alarm para eventos de segurança
resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  provider = aws.audit
  
  alarm_name          = "UnauthorizedAPICalls"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This metric monitors unauthorized API calls"
  
  alarm_actions = [aws_sns_topic.security_alerts.arn]
}

# SNS Topic para alertas de segurança
resource "aws_sns_topic" "security_alerts" {
  provider = aws.audit
  
  name = "security-alerts"
}