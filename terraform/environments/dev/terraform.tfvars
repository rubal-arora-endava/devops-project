tags = {
  Environment = "dev"
  Owner       = "Rubal Arora"
  CostCenter  = "DevOps"
  Purpose     = "Evaluation"
  Project     = "DevOps-Evaluation"
}

subnets = {
  web = {
    name             = "snet-web"
    address_prefixes = ["10.0.1.0/24"]
  }
}

web_nsg_rules = {
  ssh = {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "<admin-source-cidr>"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
  http = {
    name                       = "Allow-HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    destination_port_range     = "80"
  }
}

# Replace these values before deploy.
# ssh_public_key must be your actual SSH public key line.
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFbp2GK1bOfYoszf72oT+zJIj+6GnbZtkdm5CvH/8QD1YzJHA1YTI6AqT12/VB8smPoNV+ryM2Tb8OarHvX7RgUAgBv5LO12/WHQNAIy8OkwWRU4P9pGmbZQMFMvMCRRDwKcYs02bV/BHRTjvXRt5XexNS5wiKjEeG5/v97BrmNry7vnznAMMd2Cu4lXbmLMEkGaurrbHojfn5Cwe4GqlMxeC3aXMcZmTEV9YHwpVIGvirkIrasTjOBHR7UHxMACNMC3mu8Gp3t6PLsBf9KIyQNBTA+AverB+ZyVyhKMzvuqVo18xfrXINFDQGpjIlPZFBQimNC5n3qUReZ5mgw47GsczQdMkLWs6XVCm0KN7/nNPE4f0Z72/CsqHL50F4PV5KT/MWJeHEatOeK7GMKxW3sC5q3zokz388fCSUi1sS4KjhgNKFf4spnR8H9dBgm19FioBWjeH/3l1DJ3u7tbeQf9AKby+8efdCEMaPq3ix3AlHrVgxVu5hReaaJWUhhhvkVyXIK8ya7VN8ZHzLPg3AlAxV897riZ7Rqlnrr7AaZ8wZ9ObjRjvMqfkXeR39glYC1QcDOsJz/+GDFtC9ksWvRe0iQb2dRvV75lateHu+32l+ZZxFmlOcxcVHNQbTgvAuYC1kptjGRS+cC5E6PANgwV7dJJITEO82UZQk5nQkrQ== endava\rarora@ENDAUTOtW38Kcmn"

# Replace with your current public IP /32.
admin_source_cidr = "203.0.113.56/32"

# Disable monitoring if you do not have Log Analytics write permission.
enable_monitoring = false
