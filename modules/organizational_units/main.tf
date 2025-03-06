# modules/organizational_units/main.tf

data "aws_organizations_organization" "current" {}

locals {
  root_id = var.root_ou_id != "" ? var.root_ou_id : data.aws_organizations_organization.current.roots[0].id
  
  # Planifica a estrutura aninhada de OUs para processamento
  flat_ous = flatten([
    for parent_name, ou_config in var.ou_structure : [
      {
        name        = parent_name
        parent_id   = local.root_id
        description = try(ou_config.description, "")
        tags        = try(ou_config.tags, {})
      },
      [
        for child_name, child_config in try(ou_config.children, {}) : {
          name        = child_name
          parent_name = parent_name
          description = try(child_config.description, "")
          tags        = try(child_config.tags, {})
        }
      ]
    ]
  ])
  
  # Map para armazenar IDs de OUs criados
  parent_ous = { for ou in aws_organizations_organizational_unit.parent : ou.name => ou.id }
}

# Criar OUs de primeiro nível (sob o Root)
resource "aws_organizations_organizational_unit" "parent" {
  for_each = { for ou in local.flat_ous : ou.name => ou if try(ou.parent_id, "") == local.root_id }
  
  name        = each.key
  parent_id   = local.root_id
  
  tags = merge(
    {
      "ManagedBy" = "Terraform"
    },
    try(each.value.tags, {})
  )
}

# Criar OUs de segundo nível
resource "aws_organizations_organizational_unit" "child" {
  for_each = { 
    for idx, ou in local.flat_ous : 
    "${ou.parent_name}-${ou.name}" => ou 
    if try(ou.parent_name, "") != "" 
  }
  
  name      = each.value.name
  parent_id = local.parent_ous[each.value.parent_name]
  
  tags = merge(
    {
      "ManagedBy" = "Terraform"
      "ParentOU"  = each.value.parent_name
    },
    try(each.value.tags, {})
  )
  
  depends_on = [aws_organizations_organizational_unit.parent]
}

# Criar mapeamento de nomes de OUs para IDs
locals {
  all_ous = merge(
    { for ou in aws_organizations_organizational_unit.parent : ou.name => ou.id },
    { for key, ou in aws_organizations_organizational_unit.child : ou.name => ou.id }
  )
}