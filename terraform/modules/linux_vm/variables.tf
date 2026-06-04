variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type        = string
  description = "location of the resource."
}

variable "vm_size" {
  type        = string
  description = "Size of the resource."
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "network_security_group_id" {
  type = string
}

variable "lb_backend_address_pool_id" {
  type    = string
  default = ""
}

variable "enable_public_ip" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
}
