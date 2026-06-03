terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  type    = string
  default = "endava-playground"
}

# The bootstrap uses an existing resource group (Path A) and creates only
# the storage account + container inside it. The resource group's name is
# provided via `resource_group_name` and the location is read from the
# data source to avoid mismatches.
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "stdevopsevaltfs01"
  resource_group_name      = data.azurerm_resource_group.existing.name
  location                 = data.azurerm_resource_group.existing.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "dev"
    Purpose     = "TerraformState"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
