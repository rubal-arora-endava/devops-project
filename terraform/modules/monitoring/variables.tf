variable "name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that contains the workspace."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace."
  type        = string
}

variable "sku" {
  description = "Log Analytics pricing SKU."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Log retention period in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to the workspace."
  type        = map(string)
}
