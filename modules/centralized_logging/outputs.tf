# modules/centralized_logging/outputs.tf

output "cloudtrail_bucket_id" {
  description = "ID do bucket S3 de CloudTrail"
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_bucket_arn" {
  description = "ARN do bucket S3 de CloudTrail"
  value       = aws_s3_bucket.cloudtrail.arn
}

output "config_bucket_id" {
  description = "ID do bucket S3 de Config"
  value       = aws_s3_bucket.config.id
}

output "config_bucket_arn" {
  description = "ARN do bucket S3 de Config"
  value       = aws_s3_bucket.config.arn
}

output "cloudtrail_log_group_arn" {
  description = "ARN do grupo de logs do CloudWatch para CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "organization_trail_arn" {
  description = "ARN da trilha organizacional do CloudTrail"
  value       = aws_cloudtrail.organization_trail.arn
}

output "security_alerts_topic_arn" {
  description = "ARN do tópico SNS para alertas de segurança"
  value       = aws_sns_topic.security_alerts.arn
}