variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "create" {
  description = "Whether to create the resource group (true) or use an existing one (false)."
  type        = bool
  default     = true
}
