terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-dev"
    storage_account_name = "stdevopsevaltfs01"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
