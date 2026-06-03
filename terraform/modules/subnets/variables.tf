variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
  description = "Name of the resource."
}

variable "subnets" {
  type = map(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
}
