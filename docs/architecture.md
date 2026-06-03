# Architecture Overview

This solution deploys a secure Linux web workload on Azure with Terraform and Ansible.

## Components

- **Resource Group**: Central Azure resource container for the workload.
- **Virtual Network**: One VNet with a web subnet.
- **Network Security Group**: Least-privilege rules for SSH and HTTP.
- **Linux VMs**: Two Ubuntu VMs configured to run an Nginx web service.
- **Azure Load Balancer**: Public-facing load balancer that routes HTTP traffic to the VM pool.
- **Key Vault**: Secure secret store for future application secrets and certificate support.
- **Log Analytics Workspace**: Monitoring and diagnostics workspace for Azure logs.
- **Internet endpoint**: External users access the web service through the load balancer.
- **Terraform Remote State**: Stored in Azure Storage Account and container `tfstate`.

## Deployment Flow

1. Terraform provisions Azure infrastructure.
2. VMs are created with SSH access and assigned NSGs.
3. The load balancer attaches to the VM backend pool.
5. Ansible deploys Nginx and configures the web service.
6. Application health is validated via `/`.

## Diagram assets

- `docs/architecture.drawio` — draw.io XML import file that can be opened directly in draw.io.
- `docs/architecture.jpg` — generated architecture diagram image for quick review and documentation.
