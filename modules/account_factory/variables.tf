variable "accounts" {
  description = "Mapa de configurações de contas a serem criadas"
  type = map(object({
    name    = string
    email   = string
    ou_name = string
    tags    = map(string)
  }))
}

variable "ou_mapping" {
  description = "Mapeamento de nomes de OUs para seus IDs"
  type        = map(string)
}