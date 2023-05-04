variable "policy_definition_name" {
  type = string
}

variable "policy_definition_display_name" {
  type = string
}

variable "policy_definition_description" {
  type = string
}

variable "policy_definition_metadata" {
  type = string
}

variable "policy_definition_policy_rule" {
  type = string
}

variable "policy_definition_parameters" {
  type = string
}

variable "create_assignment" {
  type    = bool
  default = false
}

variable "policy_definition_location" {
  type = string
}