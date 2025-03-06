# modules/centralized_logging/variables.tf

variable "aws_region" {
  description = "A região AWS onde os recursos de logging serão implantados"
  type        = string
  default     = "us-east-1"
}

variable "log_archive_account_id" {
  description = "ID da conta de arquivamento de logs (log archive) do AWS Control Tower"
  type        = string
}

variable "audit_account_id" {
  description = "ID da conta de auditoria do AWS Control Tower"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "Nome do bucket S3 para armazenar logs do CloudTrail"
  type        = string
  default     = "centralized-cloudtrail-logs"
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.cloudtrail_bucket_name))
    error_message = "O nome do bucket deve estar em conformidade com as regras de nomenclatura da AWS para buckets S3."
  }
}

variable "config_bucket_name" {
  description = "Nome do bucket S3 para armazenar logs do AWS Config"
  type        = string
  default     = "centralized-config-logs"
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.config_bucket_name))
    error_message = "O nome do bucket deve estar em conformidade com as regras de nomenclatura da AWS para buckets S3."
  }
}

variable "log_retention_period" {
  description = "Período de retenção para logs em dias"
  type        = number
  default     = 731  # 2 anos por padrão
  
  validation {
    condition     = var.log_retention_period >= 90
    error_message = "O período de retenção de logs deve ser de pelo menos 90 dias para conformidade com muitos requisitos regulatórios."
  }
}

variable "enable_cloudtrail_insights" {
  description = "Flag para habilitar os insights do CloudTrail"
  type        = bool
  default     = true
}

variable "enable_config_recorder" {
  description = "Flag para habilitar o gravador de configuração do AWS Config"
  type        = bool
  default     = true
}

variable "security_alert_email" {
  description = "Endereço de email para receber alertas de segurança"
  type        = string
  default     = null
}

variable "data_resource_types" {
  description = "Tipos de recursos para incluir no monitoramento de eventos de dados do CloudTrail"
  type        = list(object({
    type   = string
    values = list(string)
  }))
  default     = [
    {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  ]
}

variable "cloudwatch_logs_retention" {
  description = "Período de retenção para logs do CloudWatch (em dias)"
  type        = number
  default     = 365
}