# Key Vault and Secret Handling

The dev environment uses Azure Key Vault as the central secret store.

## What Terraform Creates

- A Key Vault from `terraform/modules/keyvault`.
- A Terraform access policy for the current deployment identity with secret get/list/set/delete/recover/purge permissions.
- A sample Key Vault secret named by `var.app_secret_name`, defaulting to `app-welcome-message`.
- VM managed identity access policies with get/list permissions so application code can read secrets without storing credentials on the VM.

## How to Supply Secrets

Never commit real secret values to `terraform.tfvars`.

For local runs, either create `terraform/environments/dev/secret.tfvars`:

```hcl
app_secret_value = "replace-with-a-runtime-secret-value"
```

Or set an environment variable before running Terraform:

```bash
export TF_VAR_app_secret_value="$(openssl rand -base64 32)"
```

For GitHub Actions, set the repository or `development` environment secret:

```text
APP_SECRET_VALUE
```

The workflows pass that value to Terraform as `TF_VAR_app_secret_value`.

## Important State Caveat

Terraform marks `app_secret_value` as sensitive, so it is hidden from CLI output. Terraform-managed secret values can still be stored in Terraform state. Protect local state files and remote backend storage with least-privilege access.

For production, prefer one of these stronger patterns:

- Create secret containers with Terraform, then set secret values through a separate controlled release process.
- Use Key Vault references from the application platform where supported.
- Use managed identity to read secrets at runtime instead of placing secret values in source code, images, or VM files.

## Verification

After apply, verify in Azure:

1. Open the Key Vault.
2. Confirm the `app-welcome-message` secret exists.
3. Confirm the VM managed identities have get/list access.
4. Confirm no real secret values are committed to Git.
