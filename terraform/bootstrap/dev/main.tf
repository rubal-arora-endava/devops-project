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
  default = "rg-tfstate-dev"
}

variable "location" {
  type    = string
  default = "East US"
}

resource "azurerm_resource_group" "bootstrap" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Environment = "dev"
    Purpose     = "TerraformState"
    Owner       = "Rubal Arora"
    Project     = "DevOps-Evaluation"
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "stdevopsevaltfs01"
  resource_group_name      = azurerm_resource_group.bootstrap.name
  location                 = azurerm_resource_group.bootstrap.location
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
