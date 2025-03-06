# modules/control_tower_setup/main.tf

resource "aws_controltower_landing_zone" "landing_zone" {
  count = var.enable_landing_zone ? 1 : 0
  
  home_region                           = var.home_region
  enable_drift_detection                = var.enable_drift_detection
  enable_identity_center                = var.enable_identity_center
  notification_email                    = var.notification_email
  parent_organizational_unit_name       = "Root"
  organization_admin_role_name          = var.organization_admin_role_name
  core_organizational_unit_name         = "Core"
  security_organizational_unit_name     = "Security"
  sandbox_organizational_unit_name      = "Sandbox"
  security_account_email                = var.security_account_email
  logging_account_email                 = var.logging_account_email
  enable_cloudtrail                     = var.enable_cloudtrail
  enable_aws_config                     = var.enable_config
  enable_guardrails                     = var.enable_guardrails
  enable_tag_policies                   = var.enable_tag_policies
  enable_service_catalog_portfolio      = var.enable_service_catalog_portfolio
  enable_ai_services_opt_out_policy     = var.enable_ai_services_opt_out_policy
  enable_backup_policies                = var.enable_backup_policies
  enable_security_hub                   = var.enable_security_hub
  
  timeouts {
    create = "3h"
    update = "3h"
    delete = "3h"
  }
}

# Configuração de AWS Config Aggregator para centralização
resource "aws_config_configuration_aggregator" "organization" {
  count = var.enable_config_aggregator ? 1 : 0
  
  name = "organization-config-aggregator"
  
  organization_aggregation_source {
    all_regions = true
    role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
  }
  
  depends_on = [aws_controltower_landing_zone.landing_zone]
}

# Verificação de status da configuração do Control Tower
resource "null_resource" "control_tower_status_check" {
  count = var.enable_landing_zone ? 1 : 0
  
  provisioner "local-exec" {
    command = <<EOF
      aws controltower get-landing-zone-status --region ${var.home_region} --query 'LandingZoneStatus' --output text
    EOF
  }
  
  depends_on = [aws_controltower_landing_zone.landing_zone]
}

# Habilitar o Security Hub na conta de gerenciamento
resource "aws_securityhub_account" "security_hub" {
  count = var.enable_security_hub ? 1 : 0
  
  depends_on = [aws_controltower_landing_zone.landing_zone]
}

# Habilitar standards do Security Hub
resource "aws_securityhub_standards_subscription" "cis" {
  count = var.enable_security_hub ? 1 : 0
  
  standards_arn = "arn:aws:securityhub:${var.home_region}::standards/cis-aws-foundations-benchmark/v/1.2.0"
  
  depends_on = [aws_securityhub_account.security_hub]
}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count = var.enable_security_hub ? 1 : 0
  
  standards_arn = "arn:aws:securityhub:${var.home_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
  
  depends_on = [aws_securityhub_account.security_hub]
}

data "aws_caller_identity" "current" {}