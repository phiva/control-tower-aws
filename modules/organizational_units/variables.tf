# modules/organizational_units/variables.tf

variable "root_ou_id" {
  description = "ID da OU raiz na AWS Organizations. Se não for fornecido, será usado o ID raiz da organização atual."
  type        = string
  default     = ""
}

variable "ou_structure" {
  description = "Estrutura de Unidades Organizacionais (OUs) a serem criadas, suportando hierarquia de dois níveis."
  type        = map(object({
    description = optional(string, "")
    tags        = optional(map(string), {})
    children    = optional(map(object({
      description = optional(string, "")
      tags        = optional(map(string), {})
    })), {})
  }))
  default     = {}

  validation {
    condition     = length(var.ou_structure) > 0
    error_message = "A estrutura de OUs deve conter pelo menos uma OU de nível superior."
  }
}