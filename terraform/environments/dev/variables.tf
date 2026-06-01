variable "resource_group_name" {
  type    = string
  default = "rg-devops-eval-dev"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "vnet_name" {
  type    = string
  default = "vnet-devops-dev"
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnets" {
  type = map(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
}

variable "web_nsg_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = string
    destination_address_prefix = string
    destination_port_range     = string
  }))
}

variable "load_balancer_name" {
  type    = string
  default = "lb-devops-dev"
}

variable "vm_name_prefix" {
  type    = string
  default = "webvm-devops"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type = string
}

variable "admin_source_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "SSH access source CIDR block. Set this to your IP when deploying."
}

variable "key_vault_name" {
  type    = string
  default = "kv-devops-dev"
}

variable "log_analytics_name" {
  type    = string
  default = "law-devops-dev"
}

variable "tags" {
  type = map(string)
}
