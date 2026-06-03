# Deployment Guide

## Prerequisites
- Azure subscription and service principal credentials
- Terraform 1.5+
- Ansible 2.12+
- SSH key pair available for remote access
- GitHub repository with the project code
- GitHub repository secrets configured for Azure authentication

## GitHub secrets
Store these values as GitHub repository secrets, not in source code:
- `ARM_SUBSCRIPTION_ID` = `<subscription-id>`
- `ARM_TENANT_ID` = `<tenant-id>`
- `ARM_CLIENT_ID` = `<client-id>`
- `ARM_CLIENT_SECRET` = `<service-principal-secret>`

Use repository-level secrets for this project. GitHub environment-level secrets are useful when promoting to different stages (dev/prod), but for a single repo and single environment the repository secrets are sufficient.

## Terraform Deployment

1. Authenticate to Azure:
   ```bash
   az login
   az account set --subscription "<your-subscription-id>"
   ```

2. If you have backend storage permissions and want remote state:
   ```bash
   cd terraform/bootstrap/dev
   terraform init
   terraform apply
   ```

3. If you do not have storage account permission, use local Terraform state instead:
   - rename `terraform/environments/dev/backend.tf` to `terraform/environments/dev/backend.tf.disabled`
   - Terraform will then use local state in `terraform/environments/dev/terraform.tfstate`

4. Deploy infrastructure:
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan -out=tfplan -var-file=secret.tfvars
   terraform apply tfplan
   ```

4. Capture outputs:
   ```bash
   terraform output
   ```

5. Before apply, update `admin_source_cidr` in `terraform/environments/dev/terraform.tfvars` to the public IP address range from which you will SSH.

6. If you are using the local-state workaround because backend storage cannot be created, keep `terraform/environments/dev/backend.tf.disabled` in place. The state file will be created locally as `terraform/environments/dev/terraform.tfstate`.

7. If you use a custom Key Vault name, make sure it is globally unique. The default name `kv-devops-dev` may conflict with existing Azure Key Vault names.

## Ansible Deployment

1. Update the inventory file with actual VM IP addresses:
   `ansible/inventory/dev.yml`

2. Install Ansible requirements:
   ```bash
   cd ansible
   ansible-galaxy install -r requirements.yml
   ```

3. Run the deployment playbook:
   ```bash
   ansible-playbook playbooks/deploy.yml
   ```

## Validation
- Confirm the load balancer public IP is reachable on port 80.
- Validate the web service endpoint at `/`.
- Check `az monitor log-analytics query` if required.
