# Terraform CI Pipeline

The repository has separate workflows for validation, planning, and deployment.

## Workflows

- `.github/workflows/terraform-validate.yml`
  - Runs on pull requests that change Terraform and on pushes to `main` or `dev`.
  - Runs `terraform fmt -check -recursive terraform/`.
  - Runs `terraform init -backend=false -input=false`.
  - Runs `terraform validate`.

- `.github/workflows/terraform-plan.yml`
  - Manual `workflow_dispatch` pipeline.
  - Runs fmt, Azure login, init, validate, and plan.
  - Uses GitHub OIDC for Azure login.

- `.github/workflows/terraform-deploy.yml`
  - Manual `workflow_dispatch` pipeline.
  - Runs fmt, Azure login, init, validate, plan, and apply.
  - Use this only after reviewing the plan behavior and confirming the target environment.

## Required GitHub Secrets

Configure these as repository secrets or in the `development` GitHub environment:

```text
ARM_CLIENT_ID
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
APP_SECRET_VALUE
```

The Azure app registration or managed identity must have a federated credential that trusts this GitHub repository and environment for OIDC login. The workflows do not require `ARM_CLIENT_SECRET`.

## Run Fmt, Validate, and Plan in Pipeline

1. Push a branch or open a pull request to trigger `Terraform Validate`.
2. In GitHub Actions, open `Terraform Plan`.
3. Select `Run workflow`.
4. Review these steps in the run:

   ```text
   Terraform Fmt Check
   Azure Login
   Terraform Init
   Terraform Validate
   Terraform Plan
   ```

5. Review the plan output before running any deployment workflow.

## Backend Note

The repository currently keeps the backend file as `backend.tf.disabled`, so local state is used unless you rename it to `backend.tf` and bootstrap the Azure Storage backend. For shared CI plans, remote state is recommended so the plan compares against the real deployed state instead of a fresh local state file.
