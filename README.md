# devops-project

Azure DevOps evaluation project using Terraform for Azure infrastructure and Ansible for Linux web server configuration.

## What This Deploys

- Existing Azure resource group reference.
- Virtual network and web subnet.
- Network Security Group with SSH and HTTP rules.
- Two Ubuntu Linux VMs with system-assigned managed identities.
- Standard public Azure Load Balancer.
- Azure Key Vault with runtime secret storage and VM get/list access.
- Optional Log Analytics workspace and diagnostic settings.
- Ansible-managed Nginx web service.

## Repository Structure

```text
.
|-- .github/workflows/        # Terraform validate, plan, and deploy workflows
|-- ansible/                  # Inventory, playbooks, and roles
|-- docs/                     # Architecture and operating guides
`-- terraform/
    |-- bootstrap/dev/        # Optional Azure Storage backend bootstrap
    |-- environments/dev/     # Dev environment composition
    `-- modules/             # Reusable Terraform modules
```

## Key Docs

- [Deployment and destroy guide](docs/DEPLOYMENT.md)
- [Key Vault and secret handling](docs/SECRETS.md)
- [Monitoring and logging](docs/MONITORING.md)
- [Terraform CI pipeline](docs/TERRAFORM_PIPELINE.md)
- [Terraform structure](docs/terraform-structure.md)
- [Architecture overview](docs/architecture.md)

## Quick Start

1. Create `terraform/environments/dev/secret.tfvars` from `secret.tfvars.example`.
2. Set `app_secret_value` in that local file or through `TF_VAR_app_secret_value`.
3. Initialize, validate, plan, and apply:

   ```bash
   cd terraform/environments/dev
   terraform init -backend=false
   terraform fmt -recursive ../..
   terraform validate
   terraform plan -out=tfplan -var-file=secret.tfvars
   terraform apply tfplan
   ```

4. Update `ansible/inventory/dev.yml` with VM IPs from `terraform output`.
5. Run Ansible:

   ```bash
   cd ../../../ansible
   ansible-galaxy install -r requirements.yml
   ansible-playbook playbooks/deploy.yml
   ```

## CI

The manual `Terraform Plan` workflow runs fmt, validate, and plan through GitHub Actions. Configure these secrets before running it:

```text
ARM_CLIENT_ID
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
APP_SECRET_VALUE
```

The workflows use GitHub OIDC for Azure authentication and do not require an Azure client secret.
