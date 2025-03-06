# modules/guardrails/main.tf

# Implementar Service Control Policies (SCPs) como guardrails
resource "aws_organizations_policy" "security_scp" {
  for_each = var.security_guardrails
  
  name        = each.key
  description = each.value.description
  content     = each.value.policy_document
  type        = "SERVICE_CONTROL_POLICY"
  
  tags = merge(
    {
      "ManagedBy" = "Terraform",
      "Category"  = "Security"
    },
    try(each.value.tags, {})
  )
}

resource "aws_organizations_policy" "compliance_scp" {
  for_each = var.compliance_guardrails
  
  name        = each.key
  description = each.value.description
  content     = each.value.policy_document
  type        = "SERVICE_CONTROL_POLICY"
  
  tags = merge(
    {
      "ManagedBy" = "Terraform",
      "Category"  = "Compliance"
    },
    try(each.value.tags, {})
  )
}

# Policy attachments para OUs
resource "aws_organizations_policy_attachment" "security_scp_attachment" {
  for_each = {
    for pair in flatten([
      for policy_name, policy in var.security_guardrails : [
        for target_ou in try(policy.target_ous, []) : {
          policy_name = policy_name
          ou_id       = var.guardrails_target_ou_ids[target_ou]
        }
      ]
    ]) : "${pair.policy_name}-${pair.ou_id}" => pair
  }
  
  policy_id = aws_organizations_policy.security_scp[each.value.policy_name].id
  target_id = each.value.ou_id
}

resource "aws_organizations_policy_attachment" "compliance_scp_attachment" {
  for_each = {
    for pair in flatten([
      for policy_name, policy in var.compliance_guardrails : [
        for target_ou in try(policy.target_ous, []) : {
          policy_name = policy_name
          ou_id       = var.guardrails_target_ou_ids[target_ou]
        }
      ]
    ]) : "${pair.policy_name}-${pair.ou_id}" => pair
  }
  
  policy_id = aws_organizations_policy.compliance_scp[each.value.policy_name].id
  target_id = each.value.ou_id
}

# Implementar AWS Config Rules como guardrails adicionais
resource "aws_config_organization_managed_rule" "config_rules" {
  for_each = var.mandatory_guardrails
  
  name            = each.key
  rule_identifier = each.value.rule_identifier
  
  resource_types_scope = try(each.value.resource_types, null)
  input_parameters     = try(each.value.parameters, null)
  
  excluded_accounts = try(each.value.excluded_accounts, [])
  
  depends_on = [aws_organizations_policy_attachment.security_scp_attachment, aws_organizations_policy_attachment.compliance_scp_attachment]
}