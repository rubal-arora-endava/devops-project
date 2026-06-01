# devops-project

This repository contains an Azure DevOps evaluation implementation using Terraform for infrastructure provisioning and Ansible for Linux application deployment.

## Repository structure

- `terraform/` - Azure infrastructure as code
- `ansible/` - configuration management and deployment playbooks
- `docs/` - architecture diagrams, deployment guide, and supporting documentation
- `.github/workflows/` - CI pipeline for Terraform validation and plan

devops-project/
├── README.md
├── docs/
│   ├── architecture.md
│   ├── architecture-diagram.png
│   ├── daily-updates.md
│   └── walkthrough.md
├── terraform/
│   ├── bootstrap/
│   │   └── dev/
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf
│   │       ├── providers.tf
│   │       ├── backend.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       ├── terraform.tfvars
│   │       └── .terraform.lock.hcl
│   └── modules/
│       ├── resource_group/
│       ├── vnet/
│       ├── subnets/
│       ├── nsg/
│       ├── linux_vm/
│       ├── load_balancer/
│       ├── keyvault/
│       └── monitoring/
├── ansible/
│   ├── README.md
│   ├── ansible.cfg
│   ├── inventory/
│   │   └── dev.yml
│   ├── playbooks/
│   │   └── deploy.yml
│   ├── requirements.yml
│   ├── roles/
│   │   ├── base/
│   │   ├── java/
│   │   └── webserver/
│   │       ├── handlers/main.yml
│   │       ├── tasks/main.yml
│   │       └── templates/index.html.j2
│   └── group_vars/
│       └── all.yml
└── .github/
    └── workflows/
        └── terraform-validate.yml


## Terraform state approach:

Create one Azure Storage Account only for state, for example:

Resource group: rg-dte-rubal-tfstate-dev
Storage account: stdterubaltfstate
Container: tfstate
State key: devops-project/dev.terraform.tfstate

In backend.tf:

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-dte-rubal-tfstate-dev"
    storage_account_name = "stdterubaltfstate"
    container_name       = "tfstate"
    key                  = "devops-project/dev.terraform.tfstate"
  }
}

You create the backend storage once manually or with a small terraform/bootstrap folder. After that, normal Terraform uses remote state.

## Getting started

1. Configure GitHub repository secrets for Azure authentication. The workflows use the existing ARM_* secrets:
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET`
   - `ARM_SUBSCRIPTION_ID`
   - `ARM_TENANT_ID`

   You may also optionally configure an `AZURE_CREDENTIALS` JSON secret if you prefer, but it is not required.

2. Create a local secret vars file for Terraform values that should not be committed:
   - `terraform/environments/dev/secret.tfvars`
   - Add this file to `.gitignore`

   Example `terraform/environments/dev/secret.tfvars`:
   ```hcl
   ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFbp2GK1bOfYos..."
   admin_source_cidr = "x.y.z.z/32"
   ```

3. Provision the Terraform backend:
   ```bash
   cd terraform/bootstrap/dev
   terraform init
   terraform apply
   ```

3. Deploy infrastructure:
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

4. CI workflows:
   - `terraform-validate.yml` runs on PRs and does `terraform fmt -check` and `terraform validate` only.
   - `terraform-plan.yml` is a manual workflow that runs `terraform plan` against the remote backend after bootstrap.
   - `terraform-deploy.yml` is a manual workflow that runs `terraform plan` and then `terraform apply` against the remote backend once the backend and Azure auth are ready.


4. Update Ansible inventory with VM IPs.
5. Run Ansible deployment:
   ```bash
   cd ansible
   ansible-galaxy install -r requirements.yml
   ansible-playbook playbooks/deploy.yml
   ```
## Define naming and tags
### Tags:

owner       = "rubal.arora@endava.com"
environment = "dev"
cost_center = "devops-evaluation"
purpose     = "technical-evaluation"


## Notes

- The Terraform backend is configured to use Azure Storage Account state.
- The Ansible playbook deploys an Nginx web service and validates the root endpoint.
- Replace placeholder SSH key and IP addresses before running playbooks.
