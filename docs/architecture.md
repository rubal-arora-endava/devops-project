# Architecture Overview

This solution deploys a secure Linux web workload on Azure with Terraform and Ansible.

## Components

- **Resource Group**: Existing Azure resource container for the workload.
- **Virtual Network**: One VNet with a web subnet.
- **Network Security Group**: Least-privilege SSH and HTTP rules for web access.
- **Linux VMs**: Two Ubuntu VMs configured to run an Nginx web service.
- **Managed Identities**: System-assigned VM identities used for Key Vault access.
- **Azure Load Balancer**: Public-facing load balancer that routes HTTP traffic to the VM pool.
- **Key Vault**: Secure secret store for runtime application values.
- **Log Analytics Workspace**: Optional monitoring and diagnostics workspace for Azure logs.
- **Internet Endpoint**: External users access the web service through the load balancer.
- **Terraform State**: Local state by default, with an optional Azure Storage backend bootstrap.

## Deployment Flow

1. Terraform provisions Azure infrastructure.
2. VMs are created with SSH access and system-assigned managed identities.
3. Terraform stores the configured sample application secret in Key Vault.
4. VM managed identities receive get/list permissions for Key Vault secrets.
5. The load balancer attaches to the VM backend pool.
6. Optional diagnostic settings send supported logs and metrics to Log Analytics.
7. Ansible deploys Nginx and configures the web service.
8. Application health is validated through the load balancer.

## Diagram Assets

- `docs/architecture-diagram.png` - architecture diagram image for quick review and documentation.
