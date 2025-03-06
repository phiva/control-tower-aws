# modules/control_tower_setup/variables.tf

variable "home_region" {
  description = "A região AWS principal onde o Control Tower será implantado"
  type        = string
  default     = "us-east-1"
}

variable "enable_landing_zone" {
  description = "Flag para habilitar a criação da landing zone do AWS Control Tower"
  type        = bool
  default     = true
}

variable "enable_drift_detection" {
  description = "Flag para habilitar a detecção de drift no Control Tower"
  type        = bool
  default     = true
}

variable "enable_identity_center" {
  description = "Flag para habilitar o AWS IAM Identity Center (anteriormente SSO)"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Endereço de email para notificações do Control Tower"
  type        = string
}

variable "organization_admin_role_name" {
  description = "Nome da IAM role para administração da organização"
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "security_account_email" {
  description = "Endereço de email para a conta de segurança do Control Tower"
  type        = string
}

variable "logging_account_email" {
  description = "Endereço de email para a conta de logging do Control Tower"
  type        = string
}

variable "enable_cloudtrail" {
  description = "Flag para habilitar o AWS CloudTrail"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Flag para habilitar o AWS Config"
  type        = bool
  default     = true
}

variable "enable_guardrails" {
  description = "Flag para habilitar os guardrails do Control Tower"
  type        = bool
  default     = true
}

variable "enable_tag_policies" {
  description = "Flag para habilitar políticas de tags"
  type        = bool
  default     = true
}

variable "enable_service_catalog_portfolio" {
  description = "Flag para habilitar o portfólio do Service Catalog"
  type        = bool
  default     = true
}

variable "enable_ai_services_opt_out_policy" {
  description = "Flag para habilitar a política de opt-out de serviços de IA"
  type        = bool
  default     = false
}

variable "enable_backup_policies" {
  description = "Flag para habilitar políticas de backup"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Flag para habilitar o AWS Security Hub"
  type        = bool
  default     = true
}

variable "enable_config_aggregator" {
  description = "Flag para habilitar o AWS Config Aggregator"
  type        = bool
  default     = true
}