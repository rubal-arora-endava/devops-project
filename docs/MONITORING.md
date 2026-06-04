# Monitoring and Logging

Monitoring is controlled by `enable_monitoring` in `terraform/environments/dev`.

## Current Setup

When `enable_monitoring = true`, Terraform creates:

- A Log Analytics workspace from `terraform/modules/monitoring`.
- Diagnostic settings for Key Vault.
- Diagnostic settings for the web Network Security Group.
- Diagnostic settings for the public load balancer.

The diagnostic settings read supported categories from Azure with `azurerm_monitor_diagnostic_categories`, so the code does not hardcode fragile category names.

## Enable Monitoring

1. Activate or request the required Azure roles:

   ```text
   Log Analytics Contributor
   Monitoring Contributor
   ```

2. Set monitoring on:

   ```hcl
   enable_monitoring = true
   ```

3. Optional: tune workspace settings:

   ```hcl
   log_analytics_sku     = "PerGB2018"
   log_retention_in_days = 30
   ```

4. Run:

   ```bash
   cd terraform/environments/dev
   terraform plan -out=tfplan -var-file=secret.tfvars
   terraform apply tfplan
   ```

## Verify

In the Azure portal:

1. Open the Log Analytics workspace.
2. Open Diagnostic settings on the Key Vault, NSG, and load balancer.
3. Confirm each resource sends logs and metrics to the workspace where supported.
4. Use Logs in the workspace to query emitted records after traffic reaches the load balancer.

If the role is not available yet, keep `enable_monitoring = false`. The code is ready, and apply can be run after access is granted.
