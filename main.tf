# main.tf - Módulo principal para AWS Control Tower Landing Zone

provider "aws" {
  region = var.aws_region
  # Assumindo que estamos na conta de gerenciamento (management account)
}

# Módulo para configuração inicial do AWS Control Tower
module "control_tower_setup" {
  source = "./modules/control_tower_setup"
  
  home_region                       = var.aws_region
  logging_account_email             = var.logging_account_email
  security_account_email            = var.security_account_email
  enable_cloudtrail                 = true
  enable_config                     = true
  enable_guardrails                 = true
  enable_security_hub               = var.enable_security_hub
  enable_config_aggregator          = true
  enable_service_catalog_portfolio  = true
}

# Módulo para estrutura organizacional (OUs)
module "organizational_units" {
  source = "./modules/organizational_units"
  
  depends_on = [module.control_tower_setup]
  
  root_ou_id      = var.root_ou_id
  ou_structure    = var.ou_structure
}

# Módulo para guardrails (políticas de segurança)
module "guardrails" {
  source = "./modules/guardrails"
  
  depends_on = [module.organizational_units]
  
  security_guardrails      = var.security_guardrails
  compliance_guardrails    = var.compliance_guardrails
  mandatory_guardrails     = var.mandatory_guardrails
  guardrails_target_ou_ids = module.organizational_units.ou_ids
}

# Módulo para logging e monitoramento centralizado
module "centralized_logging" {
  source = "./modules/centralized_logging"
  
  depends_on = [module.control_tower_setup]
  
  log_archive_account_id   = module.account_factory.account_ids["log_archive"]
  audit_account_id         = module.account_factory.account_ids["audit"]
  cloudtrail_bucket_name   = var.cloudtrail_bucket_name
  config_bucket_name       = var.config_bucket_name
  log_retention_period     = var.log_retention_period
  enable_cloudtrail_insights = true
  enable_config_recorder     = true
}

# Módulo de Account Factory para criar contas específicas
module "account_factory" {
  source = "./modules/account_factory"
  
  depends_on = [module.organizational_units]
  
  accounts = {
    log_archive = {
      email     = "aws.alterdata.archive@alterdata.com.br"
      name      = "Log Archive"
      ou_name   = "Security"
      tags      = { Function = "Logging", Environment = "Production" }
    },
    transit_hub = {
      email     = "aws.alterdata.hub@alterdata.com.br"
      name      = "Transit Hub"
      ou_name   = "Infrastructure"
      tags      = { Function = "Networking", Environment = "Production" }
    },
    data = {
      email     = "aws.alterdata.data@alterdata.com.br"
      name      = "Data Lake"
      ou_name   = "Data"
      tags      = { Function = "DataManagement", Environment = "Production" }
    },
    audit = {
      email     = "aws.alterdata.audit@alterdata.com.br"
      name      = "Audit"
      ou_name   = "Security"
      tags      = { Function = "Security", Environment = "Production" }
    }
  }
  
  ou_mapping = module.organizational_units.ou_mapping
}

# Módulo de Account Factory for Terraform (AFT)
module "aft" {
  source = "./modules/aft"
  
  depends_on = [module.account_factory]
  
  ct_management_account_id  = var.ct_management_account_id
  log_archive_account_id    = module.account_factory.account_ids["log_archive"]
  audit_account_id          = module.account_factory.account_ids["audit"]
  aft_management_account_id = var.aft_management_account_id
  ct_home_region            = var.aws_region
  tf_backend_region         = var.aws_region
  vpc_cidr                  = var.aft_vpc_cidr
  
  # Configurações para pipelines de customização de contas
  account_customizations_repos = var.account_customization_repos
  global_customizations_repo   = var.global_customization_repo
}