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

variable "tags" {
  type = map(string)
}
