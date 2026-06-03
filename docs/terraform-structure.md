# Terraform Structure

This repository follows a modular Terraform layout for Azure infrastructure.

## Directory layout

- `terraform/bootstrap/dev` - bootstrap resources for Terraform remote state (storage account, container, resource group)
- `terraform/environments/dev` - environment-specific deployment configuration
- `terraform/modules` - reusable modules for Azure resources

## Module responsibilities

- `resource_group` - creates Azure resource groups with tags
- `vnet` - creates the virtual network
- `subnets` - creates one or more subnets
- `nsg` - creates network security groups and least-privilege rules
- `linux_vm` - deploys Linux VMs with SSH, NIC, and optional load balancer backend registration
- `load_balancer` - creates a public Azure Load Balancer and HTTP health probe
- `keyvault` - creates an Azure Key Vault with basic access policy for deployment
- `monitoring` - creates a Log Analytics workspace

## Remote state

The backend uses an Azure Storage Account container named `tfstate` and the key `dev.terraform.tfstate`.

## Notes

- Do not hardcode secrets in Terraform files.
- Keep provider versions pinned in the environment modules.
- Use `terraform fmt` and `terraform validate` before applying.
