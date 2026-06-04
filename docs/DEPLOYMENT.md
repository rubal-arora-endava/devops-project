# Deployment and Destroy Guide

This guide deploys the dev environment from `terraform/environments/dev` and then configures the Linux VMs with Ansible.

## Prerequisites

- Azure CLI logged in to the target tenant/subscription.
- Terraform 1.5 or newer.
- Ansible 2.12 or newer. On Windows, run Ansible from WSL or another Linux control node.
- An SSH key pair for VM access.
- Azure permissions on the existing `endava-playground` resource group.
- Key Vault permissions to manage access policies and set/delete secrets.
- Monitoring permissions if `enable_monitoring = true`: Log Analytics Contributor and Monitoring Contributor are typically required.

## Prepare Runtime Values

Keep real secrets out of committed files.

1. Create a local secret variables file:

   ```bash
   cp terraform/environments/dev/secret.tfvars.example terraform/environments/dev/secret.tfvars
   ```

2. Edit `terraform/environments/dev/secret.tfvars`:

   ```hcl
   ssh_public_key    = "ssh-rsa AAAA..."
   admin_source_cidr = "203.0.113.4/32"
   app_secret_value  = "replace-with-a-runtime-secret-value"
   ```

3. Confirm `terraform/environments/dev/secret.tfvars` is not committed. It is already ignored by `.gitignore`.

You can also avoid a local secret file by setting `TF_VAR_app_secret_value` in your shell and keeping non-secret inputs in `terraform.tfvars`.

## Deploy Terraform Locally

1. Authenticate to Azure:

   ```bash
   az login
   az account set --subscription "<subscription-id>"
   ```

2. Initialize Terraform from the dev environment. The repo currently keeps `backend.tf.disabled`, so this uses local state:

   ```bash
   cd terraform/environments/dev
   terraform init -backend=false
   ```

3. Format and validate:

   ```bash
   terraform fmt -recursive ../..
   terraform validate
   ```

4. Review the plan:

   ```bash
   terraform plan -out=tfplan -var-file=secret.tfvars
   ```

5. Apply the reviewed plan:

   ```bash
   terraform apply tfplan
   ```

6. Capture outputs for Ansible:

   ```bash
   terraform output
   ```

The existing resource group is referenced with `create = false`; Terraform does not create or destroy that resource group in the environment deployment.

## Enable Monitoring

Monitoring is controlled by `enable_monitoring`.

1. Confirm you have the required Azure role activation.
2. Set this in `terraform/environments/dev/terraform.tfvars` or an override file:

   ```hcl
   enable_monitoring = true
   ```

3. Run a new plan and apply:

   ```bash
   terraform plan -out=tfplan -var-file=secret.tfvars
   terraform apply tfplan
   ```

Terraform creates a Log Analytics workspace and diagnostic settings for Key Vault, the web NSG, and the load balancer.

## Run Ansible

1. Update `ansible/inventory/dev.yml` with the VM public IPs from `terraform output`, or private IPs if your control node can reach the VNet.

2. Install Ansible requirements:

   ```bash
   cd ../../../ansible
   ansible-galaxy install -r requirements.yml
   ```

3. Run the playbook:

   ```bash
   ansible-playbook playbooks/deploy.yml
   ```

4. Validate the app through the load balancer public IP on port 80.

## Destroy Terraform Resources

Destroy uses the same variable inputs as deploy because Terraform still evaluates the configuration.

1. From the dev Terraform directory:

   ```bash
   cd terraform/environments/dev
   terraform destroy -var-file=secret.tfvars
   ```

2. Review the destroy plan and confirm when prompted.

This removes the VMs, NICs, public IPs, load balancer, NSG, VNet, Key Vault, Key Vault secret, access policies, and monitoring resources if enabled. It does not destroy the existing `endava-playground` resource group.

## Optional Remote State Bootstrap

If you have storage account permissions and want Azure remote state:

1. Create the backend storage:

   ```bash
   cd terraform/bootstrap/dev
   terraform init
   terraform apply
   ```

2. Rename `terraform/environments/dev/backend.tf.disabled` to `backend.tf`.

3. Reinitialize the dev environment:

   ```bash
   cd terraform/environments/dev
   terraform init -reconfigure
   ```

If you later need to tear down only the bootstrap storage, run `terraform destroy` from `terraform/bootstrap/dev` after the environment state has been safely migrated or destroyed.
