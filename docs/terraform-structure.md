# Terraform Structure

This repository follows a modular Terraform layout for Azure infrastructure.

## Directory Layout

- `terraform/bootstrap/dev` - optional bootstrap resources for Terraform remote state storage.
- `terraform/environments/dev` - environment-specific deployment composition.
- `terraform/modules` - reusable modules for Azure resources.

## Module Responsibilities

- `resource_group` - references or creates Azure resource groups with tags.
- `vnet` - creates the virtual network.
- `subnets` - creates one or more subnets.
- `nsg` - creates network security groups and least-privilege rules.
- `linux_vm` - deploys Linux VMs with SSH, NICs, managed identity, and optional load balancer backend registration.
- `load_balancer` - creates a public Azure Load Balancer, backend pool, HTTP health probe, and rule.
- `keyvault` - creates an Azure Key Vault; environment code manages access policies and secrets.
- `monitoring` - creates a configurable Log Analytics workspace.

## State

The dev environment currently keeps `backend.tf.disabled`, so local state is used unless that file is renamed to `backend.tf` after the optional bootstrap has created Azure Storage.

For shared CI/CD plans, remote state is recommended so pipeline plans compare against the real deployed state.

## Notes

- Do not hardcode secrets in Terraform files.
- Supply `app_secret_value` through `secret.tfvars`, `TF_VAR_app_secret_value`, or the GitHub `APP_SECRET_VALUE` secret.
- Keep provider versions pinned in the environment modules.
- Run `terraform fmt -recursive` and `terraform validate` before applying.
