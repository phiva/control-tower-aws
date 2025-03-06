# modules/organizational_units/outputs.tf

output "ou_ids" {
  description = "Mapa de todos os IDs das OUs criadas"
  value       = local.all_ous
}

output "ou_mapping" {
  description = "Mapeamento de nomes de OUs para seus IDs"
  value       = local.all_ous
}

output "parent_ou_ids" {
  description = "Mapa de IDs das OUs de primeiro nível"
  value       = local.parent_ous
}

output "root_id" {
  description = "ID da OU raiz utilizada"
  value       = local.root_id
}