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

ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD... your-public-key"

admin_source_cidr = "203.0.113.56/32"
