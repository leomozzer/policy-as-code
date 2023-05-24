data "azurerm_subscription" "current" {}
data "azurerm_management_group" "management_group" {
  name = var.management_group
}

module "whitelist_regions" {
  source              = "gettek/policy-as-code/azurerm//modules/definition"
  version             = "2.8.0"
  policy_name         = "whitelist_regions"
  display_name        = "Allow resources only in whitelisted regions"
  policy_category     = "General"
  management_group_id = data.azurerm_management_group.management_group.id
}

module "org_mg_whitelist_regions" {
  source            = "gettek/policy-as-code/azurerm//modules/def_assignment"
  version           = "2.8.0"
  definition        = module.whitelist_regions.definition
  assignment_scope  = data.azurerm_management_group.management_group.id
  assignment_effect = "Deny"

  assignment_parameters = {
    listOfRegionsAllowed = [
      "East US",
      "Central US",
      "West Europe",
      "Global"
    ]
  }
}

module "subscription_definition" {
  source  = "gettek/policy-as-code/azurerm//modules/definition"
  version = "2.8.0"
  for_each = {
    for index, policy in var.policy_rules : policy.name => policy
  }
  policy_name         = each.value.file_name
  display_name        = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.displayName
  policy_description  = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.description
  policy_category     = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.metadata.category
  policy_version      = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.metadata.version
  management_group_id = data.azurerm_management_group.management_group.id
  policy_rule         = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.policyRule
  policy_parameters   = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.parameters
  policy_metadata     = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.metadata
}

module "subscription_definition_def_assignment" {
  source  = "gettek/policy-as-code/azurerm//modules/def_assignment"
  version = "2.8.0"
  for_each = {
    for index, policy in var.policy_rules : policy.name => policy
  }
  definition       = module.subscription_definition[each.value.name].definition
  assignment_scope = data.azurerm_subscription.current.id
  skip_remediation = each.value.skip_remediation
}