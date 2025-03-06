# modules/aft/main.tf

provider "aws" {
  alias  = "ct_management"
  region = var.ct_home_region
  
  # Assumindo que estamos executando a partir da conta de gerenciamento
}

provider "aws" {
  alias  = "aft_management"
  region = var.ct_home_region
  
  assume_role {
    role_arn = "arn:aws:iam::${var.aft_management_account_id}:role/AWSControlTowerExecution"
  }
}

locals {
  aft_version = "1.9.0" # Atualizar para a versão mais recente do AFT
}

module "aft" {
  source = "github.com/aws-ia/terraform-aws-control_tower_account_factory?ref=v1.9.0"
  
  # Providers
  ct_management_account_id  = var.ct_management_account_id
  audit_account_id          = var.audit_account_id
  log_archive_account_id    = var.log_archive_account_id
  aft_management_account_id = var.aft_management_account_id
  
  # AFT Configurações
  aft_feature_cloudtrail_data_events      = true
  aft_feature_enterprise_support          = false
  aft_feature_delete_default_vpcs_enabled = true
  
  # AFT Configurações de rede
  aft_vpc_endpoints                       = true
  aft_vpc_cidr                            = var.vpc_cidr
  
  # AFT regiões
  ct_home_region                          = var.ct_home_region
  tf_backend_region                       = var.tf_backend_region
  
  # AFT Repositórios de customização
  # Customizações por conta base no GitHub
  vcs_provider                                  = "github"
  account_request_repo_name                     = var.account_request_repo_name
  global_customizations_repo_name               = var.global_customization_repo.name
  account_customizations_repo_name              = var.account_customizations_repo_name
  account_provisioning_customizations_repo_name = var.account_provisioning_customizations_repo_name
  
  # GitHub configurações
  terraform_distribution                   = "oss"
  terraform_version                        = "1.3.0"
  aft_feature_concurrent_account_factory   = true
  
  # Tags
  aft_tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Configuração de repositório de solicitação de conta
resource "aws_codecommit_repository" "account_request" {
  provider = aws.aft_management
  count    = var.vcs_provider == "codecommit" ? 1 : 0
  
  repository_name = var.account_request_repo_name
  description     = "AFT Account Request Repository"
}

# Configuração de repositório de customizações globais
resource "aws_codecommit_repository" "global_customizations" {
  provider = aws.aft_management
  count    = var.vcs_provider == "codecommit" ? 1 : 0
  
  repository_name = var.global_customization_repo.name
  description     = "AFT Global Customizations Repository"
}

# Configuração de repositório de customizações de conta
resource "aws_codecommit_repository" "account_customizations" {
  provider = aws.aft_management
  count    = var.vcs_provider == "codecommit" ? 1 : 0
  
  repository_name = var.account_customizations_repo_name
  description     = "AFT Account Customizations Repository"
}

# Configuração de repositório de customizações de provisionamento
resource "