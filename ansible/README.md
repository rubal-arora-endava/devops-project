# Ansible Deployment

This directory contains Ansible configuration for Linux VM provisioning and Nginx web service deployment.

## Prerequisites
- Ansible 2.12+
- Python 3.10+
- SSH key pair available locally
- Azure VM IP addresses from Terraform outputs

## Inventory
Edit `ansible/inventory/dev.yml` with the public or private IP addresses of the deployed VMs.

## Run playbook
```bash
cd ansible
ansible-playbook playbooks/deploy.yml
```

## What it does
- Installs common utility packages
- Creates a non-root application user
- Installs Nginx
- Deploys a static landing page to `/var/www/html/index.html`
- Enables and starts the Nginx service
- Validates the root web endpoint

## Notes
- Update the Nginx landing page template in `ansible/roles/webserver/templates/index.html.j2` if you want custom page content.
- Keep SSH private key access limited and use least-privilege network rules.
