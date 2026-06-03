output "resource_group_name" {
  value = var.create ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.existing[0].name
}

output "resource_group_id" {
  value = var.create ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.existing[0].id
}

output "resource_group_location" {
  value = var.create ? azurerm_resource_group.main[0].location : data.azurerm_resource_group.existing[0].location
}
