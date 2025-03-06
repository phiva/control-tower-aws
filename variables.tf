# variables.tf - Variáveis para AWS Control Tower Landing Zone

variable "aws_region" {
  description = "A região AWS principal onde o Control Tower será implantado"
  type        = string
  default     = "us-east-1"
}

variable "logging_account_email" {
  description = "Endereço de email para a conta de logging do Control Tower"
  type        = string
}

variable "security_account_email" {
  description = "Endereço de email para a conta de segurança do Control Tower"
  type        = string
}

variable "enable_security_hub" {
  description = "Flag para habilitar o AWS Security Hub"
  type        = bool
  default     = true
}

variable "root_ou_id" {
  description = "ID da OU raiz na AWS Organizations"
  type        = string
}

variable "ou_structure" {
  description = "Estrutura de Unidades Organizacionais (OUs) a serem criadas"
  type        = map(object({
    name        = string
    description = string
    parent_id   = string
    children    = optional(list(string))
  }))
  default     = {}
}

variable "security_guardrails" {
  description = "Lista de guardrails de segurança a serem aplicados"
  type        = list(object({
    name        = string
    description = string
    policy_id   = string
    target_ids  = list(string)
  }))
  default     = []
}

variable "compliance_guardrails" {
  description = "Lista de guardrails de compliance a serem aplicados"
  type        = list(object({
    name        = string
    description = string
    policy_id   = string
    target_ids  = list(string)
  }))
  default     = []
}

variable "mandatory_guardrails" {
  description = "Lista de guardrails obrigatórios a serem aplicados"
  type        = list(object({
    name        = string
    description = string
    policy_id   = string
    target_ids  = list(string)
  }))
  default     = []
}

variable "cloudtrail_bucket_name" {
  description = "Nome do bucket S3 para armazenar logs do CloudTrail"
  type        = string
  default     = "aws-controltower-logs-cloudtrail"
}

variable "config_bucket_name" {
  description = "Nome do bucket S3 para armazenar logs do AWS Config"
  type        = string
  default     = "aws-controltower-logs-config"
}

variable "log_retention_period" {
  description = "Período de retenção para logs em dias"
  type        = number
  default     = 365
}

variable "ct_management_account_id" {
  description = "ID da conta de gerenciamento do Control Tower"
  type        = string
}

variable "aft_management_account_id" {
  description = "ID da conta de gerenciamento do Account Factory for Terraform (AFT)"
  type        = string
}

variable "aft_vpc_cidr" {
  description = "CIDR do VPC para o AFT"
  type        = string
  default     = "10.0.0.0/16"
}

variable "account_customization_repos" {
  description = "Repositórios de customização de contas para o AFT"
  type        = map(object({
    repo_url    = string
    branch      = string
    target_path = string
  }))
  default     = {}
}

variable "global_customization_repo" {
  description = "Repositório de customização global para o AFT"
  type        = object({
    repo_url    = string
    branch      = string
    target_path = string
  })
  default     = null
}