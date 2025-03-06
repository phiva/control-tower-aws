# modules/guardrails/outputs.tf

output "security_policy_ids" {
  description = "IDs das políticas de segurança criadas"
  value       = { for name, policy in aws_organizations_policy.security_scp : name => policy.id }
}

output "compliance_policy_ids" {
  description = "IDs das políticas de compliance criadas"
  value       = { for name, policy in aws_organizations_policy.compliance_scp : name => policy.id }
}

output "config_rule_arns" {
  description = "ARNs das regras do AWS Config criadas"
  value       = { for name, rule in aws_config_organization_managed_rule.config_rules : name => rule.arn }
}
