# Ansible Structure

The Ansible design for this project follows standard role-based layout.

## Directory layout

- `ansible/ansible.cfg` - default settings for inventory and SSH configuration
- `ansible/inventory/dev.yml` - static host inventory for the development environment
- `ansible/inventory/group_vars/all.yml` - shared variables used by the dev inventory
- `ansible/roles/base` - common provisioning, package installation, and user creation
- `ansible/roles/java` - OpenJDK installation and validation
- `ansible/roles/webserver` - web server deployment and systemd service configuration for the web server
- `ansible/playbooks/deploy.yml` - main playbook that runs all roles
- `ansible/requirements.yml` - Ansible Galaxy collections required for the playbook

## Deployment flow

1. Provision VMs and network with Terraform
2. Export VM IP addresses from Terraform outputs
3. Update `ansible/inventory/dev.yml`
4. Run `ansible-playbook playbooks/deploy.yml`

## Validation

- Service status is validated with the systemd module
- Application availability is validated via the HTTP root endpoint at `/`
