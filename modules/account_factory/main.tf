# modules/account_factory/main.tf

locals {
  # Mapeamento de nomes de contas para seus valores
  account_configs = var.accounts
}

resource "aws_organizations_account" "account" {
  for_each = local.account_configs
  
  name              = each.value.name
  email             = each.value.email
  parent_id         = var.ou_mapping[each.value.ou_name]
  role_name         = "AWSControlTowerExecution"
  
  tags = merge(
    {
      "ManagedBy" = "Terraform"
    },
    each.value.tags
  )
  
  # Impede que a conta seja excluída quando o recurso Terraform for destruído
  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "wait_for_account_activation" {
  for_each = aws_organizations_account.account
  
  provisioner "local-exec" {
    command = <<EOF
      aws organizations describe-account --account-id ${each.value.id} --query 'Account.Status' --output text | grep ACTIVE
      while [ $? -ne 0 ]; do
        sleep 10
        aws organizations describe-account --account-id ${each.value.id} --query 'Account.Status' --output text | grep ACTIVE
      done
    EOF
  }
  
  depends_on = [aws_organizations_account.account]
}

# Configurar SSO para contas criadas (se AWS SSO/IAM Identity Center estiver habilitado)
data "aws_ssoadmin_instances" "this" {}

resource "aws_identitystore_group" "account_admins" {
  for_each = length(data.aws_ssoadmin_instances.this.arns) > 0 ? local.account_configs : {}
  
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  
  display_name = "${each.value.name}Admins"
  description  = "Administrators for the ${each.value.name} account"
}

resource "aws_ssoadmin_permission_set" "admin" {
  count = length(data.aws_ssoadmin_instances.this.arns) > 0 ? 1 : 0
  
  name         = "AccountAdministrator"
  description  = "Full administrator access to AWS accounts"
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "admin_policy" {
  count = length(data.aws_ssoadmin_instances.this.arns) > 0 ? 1 : 0
  
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin[0].arn
}

resource "aws_ssoadmin_account_assignment" "account_admins" {
  for_each = length(data.aws_ssoadmin_instances.this.arns) > 0 ? aws_organizations_account.account : {}
  
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin[0].arn
  
  principal_id   = aws_identitystore_group.account_admins[each.key].group_id
  principal_type = "GROUP"
  
  target_id   = each.value.id
  target_type = "AWS_ACCOUNT"
}