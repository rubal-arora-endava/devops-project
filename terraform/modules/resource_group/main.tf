resource "azurerm_resource_group" "main" {
  count    = var.create ? 1 : 0
  name     = var.name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "existing" {
  count = var.create ? 0 : 1
  name  = var.name
}
