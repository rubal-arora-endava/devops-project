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

data "azurerm_client_config" "current" {}

module "resource_group" {
  source   = "../../modules/resource_group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
  create   = false
}

module "vnet" {
  source              = "../../modules/vnet"
  name                = var.vnet_name
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

module "subnets" {
  source               = "../../modules/subnets"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.vnet.name
  subnets              = var.subnets
}

locals {
  web_nsg_rules = merge(
    var.web_nsg_rules,
    {
      ssh = merge(var.web_nsg_rules["ssh"], {
        source_address_prefix = var.admin_source_cidr
      })
    },
    contains(keys(var.web_nsg_rules), "http") ? {
      http = merge(var.web_nsg_rules["http"], {
        source_address_prefix = coalesce(var.web_source_cidr, var.admin_source_cidr)
      })
    } : {}
  )
}

module "nsg_web" {
  source              = "../../modules/nsg"
  name                = "nsg-web"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  tags                = var.tags
  security_rules      = local.web_nsg_rules
}

module "load_balancer" {
  source              = "../../modules/load_balancer"
  name                = var.load_balancer_name
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  tags                = var.tags
}

module "web_vm_1" {
  source                     = "../../modules/linux_vm"
  name                       = "${var.vm_name_prefix}-01"
  resource_group_name        = module.resource_group.resource_group_name
  location                   = module.resource_group.resource_group_location
  vm_size                    = var.vm_size
  admin_username             = var.admin_username
  ssh_public_key             = var.ssh_public_key
  subnet_id                  = module.subnets.subnet_ids["web"]
  network_security_group_id  = module.nsg_web.id
  lb_backend_address_pool_id = module.load_balancer.lb_backend_address_pool_id
  enable_public_ip           = var.enable_vm_public_ip
  tags                       = var.tags
}

module "web_vm_2" {
  source                     = "../../modules/linux_vm"
  name                       = "${var.vm_name_prefix}-02"
  resource_group_name        = module.resource_group.resource_group_name
  location                   = module.resource_group.resource_group_location
  vm_size                    = var.vm_size
  admin_username             = var.admin_username
  ssh_public_key             = var.ssh_public_key
  subnet_id                  = module.subnets.subnet_ids["web"]
  network_security_group_id  = module.nsg_web.id
  lb_backend_address_pool_id = module.load_balancer.lb_backend_address_pool_id
  enable_public_ip           = var.enable_vm_public_ip
  tags                       = var.tags
}

module "key_vault" {
  source              = "../../modules/keyvault"
  name                = var.key_vault_name
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  tags                = var.tags
}

resource "azurerm_key_vault_access_policy" "terraform_current" {
  key_vault_id = module.key_vault.keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Set",
  ]
}

resource "azurerm_key_vault_secret" "app_secret" {
  name         = var.app_secret_name
  value        = var.app_secret_value
  key_vault_id = module.key_vault.keyvault_id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.terraform_current]
}

module "monitoring" {
  source              = "../../modules/monitoring"
  count               = var.enable_monitoring ? 1 : 0
  name                = var.log_analytics_name
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_in_days
  tags                = var.tags
}

locals {
  web_vm_principal_ids = {
    web01 = module.web_vm_1.principal_id
    web02 = module.web_vm_2.principal_id
  }
}

resource "azurerm_key_vault_access_policy" "web_vms" {
  for_each = local.web_vm_principal_ids

  key_vault_id = module.key_vault.keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  secret_permissions = [
    "Get",
    "List",
  ]
}

data "azurerm_monitor_diagnostic_categories" "key_vault" {
  count       = var.enable_monitoring ? 1 : 0
  resource_id = module.key_vault.keyvault_id
}

data "azurerm_monitor_diagnostic_categories" "nsg" {
  count       = var.enable_monitoring ? 1 : 0
  resource_id = module.nsg_web.id
}

data "azurerm_monitor_diagnostic_categories" "load_balancer" {
  count       = var.enable_monitoring ? 1 : 0
  resource_id = module.load_balancer.id
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  count                      = var.enable_monitoring ? 1 : 0
  name                       = "diag-keyvault"
  target_resource_id         = module.key_vault.keyvault_id
  log_analytics_workspace_id = module.monitoring[0].workspace_id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.key_vault[0].log_category_types)
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.key_vault[0].metrics)
    content {
      category = metric.value
      enabled  = true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
  count                      = var.enable_monitoring ? 1 : 0
  name                       = "diag-nsg-web"
  target_resource_id         = module.nsg_web.id
  log_analytics_workspace_id = module.monitoring[0].workspace_id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.nsg[0].log_category_types)
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.nsg[0].metrics)
    content {
      category = metric.value
      enabled  = true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "load_balancer" {
  count                      = var.enable_monitoring ? 1 : 0
  name                       = "diag-load-balancer"
  target_resource_id         = module.load_balancer.id
  log_analytics_workspace_id = module.monitoring[0].workspace_id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.load_balancer[0].log_category_types)
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.load_balancer[0].metrics)
    content {
      category = metric.value
      enabled  = true
    }
  }
}

output "load_balancer_public_ip" {
  value = module.load_balancer.lb_public_ip
}

output "vm1_public_ip" {
  value = module.web_vm_1.public_ip
}

output "vm2_public_ip" {
  value = module.web_vm_2.public_ip
}

output "vm1_private_ip" {
  value = module.web_vm_1.private_ip
}

output "vm2_private_ip" {
  value = module.web_vm_2.private_ip
}

output "vm1_id" {
  value = module.web_vm_1.id
}

output "vm2_id" {
  value = module.web_vm_2.id
}
