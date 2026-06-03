variable "resource_group_name" {
  type    = string
  description = "Name of the resource."
  default = "endava-playground"
}

variable "location" {
  type    = string
  description = "Location of the resource."
  default = "East US"
}

variable "vnet_name" {
  type    = string
  description = "Name of the resource."
  default = "vnet-devops-dev"
}

variable "address_space" {
  type    = list(string)
  description = "Name of the resource."
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
  description = "Name of the resource."
  default = "lb-devops-dev"
}

variable "vm_name_prefix" {
  type    = string
  description = "Prefix of the resource."
  default = "webvm-devops"
}

variable "vm_size" {
  type    = string
  description = "Size of the resource."
  default = "Standard_D2s_v3"
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
  description = "Name of the resource."
  default = "kv-devops-rubal-dev"
}

variable "log_analytics_name" {
  type    = string
  description = "Name of the resource."
  default = "law-devops-dev"
}

variable "enable_monitoring" {
  description = "Enable Log Analytics and diagnostic settings. Set false if you do not have Log Analytics write permission."
  type        = bool
  default     = false
}

variable "tags" {
  type = map(string)
}
