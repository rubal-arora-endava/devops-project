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
    }
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
  enable_public_ip           = true
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
  enable_public_ip           = true
  tags                       = var.tags
}

module "key_vault" {
  source              = "../../modules/keyvault"
  name                = var.key_vault_name
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  tags                = var.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  count               = var.enable_monitoring ? 1 : 0
  name                = var.log_analytics_name
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
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

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  count                      = var.enable_monitoring ? 1 : 0
  name                       = "diag-keyvault"
  target_resource_id         = module.key_vault.keyvault_id
  log_analytics_workspace_id = try(module.monitoring[0].workspace_id, null)

  log {
    category = "AuditEvent"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
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
