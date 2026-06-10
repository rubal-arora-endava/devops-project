variable "resource_group_name" {
  description = "Name of the existing Azure resource group used for the dev environment."
  type        = string
  default     = "endava-playground"
}

variable "location" {
  description = "Azure region used when creating regional resources."
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the dev virtual network."
  type        = string
  default     = "vnet-devops-dev"
}

variable "address_space" {
  description = "Address space assigned to the dev virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnet definitions keyed by logical subnet name."
  type = map(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
}

variable "web_nsg_rules" {
  description = "Inbound NSG rules for the web subnet and VM NICs."
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
  description = "Name of the public load balancer."
  type        = string
  default     = "lb-devops-dev"
}

variable "vm_name_prefix" {
  description = "Prefix used for Linux VM names."
  type        = string
  default     = "webvm-devops"
}

variable "vm_size" {
  description = "Azure VM size for the web servers."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Linux admin username configured on each VM."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key used for VM access. Keep private keys outside the repository."
  type        = string
}

variable "admin_source_cidr" {
  description = "SSH access source CIDR block. Set this to your current public IP with /32 for deployment."
  type        = string
  default     = "0.0.0.0/0"
}

variable "web_source_cidr" {
  description = "HTTP access source CIDR block. Defaults to admin_source_cidr for demo environments; set to Internet only when the web tier is intentionally public."
  type        = string
  default     = null
}

variable "enable_vm_public_ip" {
  description = "Attach public IPs directly to VMs. Keep false for private VMs; enable only for short-lived break-glass demos."
  type        = bool
  default     = false
}

variable "key_vault_name" {
  description = "Globally unique name for the dev Key Vault."
  type        = string
  default     = "kv-devops-rubal-dev"
}

variable "app_secret_name" {
  description = "Name of the example application secret stored in Key Vault."
  type        = string
  default     = "app-welcome-message"
}

variable "app_secret_value" {
  description = "Example application secret value stored in Key Vault. Supply at runtime; never commit a real value."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(trimspace(nonsensitive(var.app_secret_value))) > 0
    error_message = "app_secret_value must be supplied at runtime and cannot be empty."
  }
}

variable "log_analytics_name" {
  description = "Name of the Log Analytics workspace used when monitoring is enabled."
  type        = string
  default     = "law-devops-dev"
}

variable "log_analytics_sku" {
  description = "Log Analytics pricing SKU."
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "Log Analytics retention period in days."
  type        = number
  default     = 30
}

variable "enable_monitoring" {
  description = "Enable Log Analytics and diagnostic settings. Set false if you do not have monitoring permissions."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to Azure resources."
  type        = map(string)
}
