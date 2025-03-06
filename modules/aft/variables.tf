# modules/aft/variables.tf

variable "ct_management_account_id" {
  description = "ID da conta de gerenciamento do AWS Control Tower"
  type        = string
}

variable "audit_account_id" {
  description = "ID da conta de auditoria do AWS Control Tower"
  type        = string
}

variable "log_archive_account_id" {
  description = "ID da conta de arquivo de logs do AWS Control Tower"
  type        = string
}

variable "aft_management_account_id" {
  description = "ID da conta de gerenciamento do AFT"
  type        = string
}

variable "ct_home_region" {
  description = "Região principal do AWS Control Tower"
  type        = string
}

variable "tf_backend_region" {
  description = "Região para o backend do Terraform"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC do AFT"
  type        = string
  default     = "10.0.0.0/16"
}

variable "account_request_repo_name" {
  description = "Nome do repositório de solicitações de conta"
  type        = string
}

variable "global_customization_repo" {
  description = "Configuração do repositório de customizações globais"
  type        = object({
    name = string
  })
}

variable "account_customizations_repo_name" {
  description = "Nome do repositório de customizações de conta"
  type        = string
}

variable "account_provisioning_customizations_repo_name" {
  description = "Nome do repositório de customizações de provisionamento de conta"
  type        = string
}

variable "vcs_provider" {
  description = "Provedor de controle de versão (github ou codecommit)"
  type        = string
  default     = "github"
  validation {
    condition     = contains(["github", "codecommit"], var.vcs_provider)
    error_message = "O provedor VCS deve ser 'github' ou 'codecommit'."
  }
}