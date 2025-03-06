# modules/guardrails/variables.tf

variable "security_guardrails" {
  description = "Mapa de guardrails de segurança a serem implementados como Service Control Policies (SCPs)"
  type = map(object({
    description     = string
    policy_document = string
    target_ous      = list(string)
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "compliance_guardrails" {
  description = "Mapa de guardrails de compliance a serem implementados como Service Control Policies (SCPs)"
  type = map(object({
    description     = string
    policy_document = string
    target_ous      = list(string)
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "mandatory_guardrails" {
  description = "Mapa de guardrails obrigatórios a serem implementados como AWS Config Rules"
  type = map(object({
    rule_identifier   = string
    resource_types    = optional(list(string))
    parameters        = optional(string)
    excluded_accounts = optional(list(string), [])
  }))
  default = {}
}

variable "guardrails_target_ou_ids" {
  description = "Mapa de nomes de OUs para seus IDs, usado para definir os alvos dos guardrails"
  type        = map(string)
}