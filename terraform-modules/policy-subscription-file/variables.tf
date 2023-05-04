variable "file_name" {
  type = string
}

variable "policy_definition_name" {
  type = string
}

variable "policy_definition_location" {
  type = string
}

variable "create_assignment" {
  type    = bool
  default = false
}