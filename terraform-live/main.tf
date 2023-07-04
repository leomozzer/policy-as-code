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
    for index, definition in var.policy_definitions : definition.name => definition
  }
  policy_name         = each.value.file_name
  display_name        = (jsondecode(file("../policies/definition/${each.value.category}/${each.value.file_name}.json"))).properties.displayName
  policy_description  = (jsondecode(file("../policies/definition/${each.value.category}/${each.value.file_name}.json"))).properties.description
  policy_category     = (jsondecode(file("../policies/definition/${each.value.category}/${each.value.file_name}.json"))).properties.metadata.category
  policy_version      = (jsondecode(file("../policies/definition/${each.value.category}/${each.value.file_name}.json"))).properties.metadata.version
  management_group_id = data.azurerm_management_group.management_group.id
  policy_rule         = (jsondecode(file("../policies/definition/${each.value.category}/${each.value.file_name}.json"))).properties.policyRule
  policy_parameters   = (jsondecode(file("../policies/definition/${each.value.category}/${each.value.file_name}.json"))).properties.parameters
  policy_metadata     = (jsondecode(file("../policies/definition/${each.value.category}/${each.value.file_name}.json"))).properties.metadata
}

module "subscription_definition_def_assignment" {
  source  = "gettek/policy-as-code/azurerm//modules/def_assignment"
  version = "2.8.0"
  for_each = {
    for index, definition in var.policy_definitions : definition.name => definition if definition.type == "policy"
  }
  definition       = module.subscription_definition[each.value.name].definition
  assignment_scope = data.azurerm_management_group.management_group.id
  skip_remediation = each.value.skip_remediation
}

### Create Initiatives
### Use the following piece only if it's required to have a initiative

locals {
  initiative_list = flatten([
    for index, initiative in var.initiative_definitions : {
      "initiative" : {
        "definitions" : [for definition in var.policy_definitions : module.subscription_definition[definition.name].definition if contains(initiative.definitions, definition.name) == true]
        "initiative_name" : initiative.initiative_name
        "initiative_display_name" : initiative.initiative_display_name
        "initiative_category" : initiative.initiative_category
        "initiative_description" : initiative.initiative_description
        "assignment_effect" : initiative.assignment_effect
        "skip_role_assignment"   = initiative.skip_role_assignment
        "skip_remediation"       = initiative.skip_remediation
        "re_evaluate_compliance" = initiative.re_evaluate_compliance
        "module_index"           = index
      }
    }
  ])
}

module "configure_initiative" {
  source  = "gettek/policy-as-code/azurerm//modules/initiative"
  version = "2.8.0"
  for_each = {
    for key, initiative in local.initiative_list : key => initiative
  }
  initiative_name         = each.value["initiative"]["initiative_name"]
  initiative_display_name = "${each.value["initiative"]["initiative_category"]}: ${each.value["initiative"]["initiative_display_name"]}"
  initiative_description  = each.value["initiative"]["initiative_description"]
  initiative_category     = each.value["initiative"]["initiative_category"]
  management_group_id     = data.azurerm_management_group.management_group.id

  member_definitions = each.value["initiative"]["definitions"]
}

module "initiative_assignment" {
  source  = "gettek/policy-as-code/azurerm//modules/set_assignment"
  version = "2.8.0"
  for_each = {
    for key, initiative in local.initiative_list : key => initiative
  }
  initiative        = module.configure_initiative[each.value["initiative"]["module_index"]].initiative
  assignment_scope  = data.azurerm_management_group.management_group.id
  assignment_effect = each.value["initiative"]["assignment_effect"]

  # resource remediation options
  skip_role_assignment   = each.value["initiative"]["skip_role_assignment"]
  skip_remediation       = each.value["initiative"]["skip_remediation"]
  re_evaluate_compliance = each.value["initiative"]["re_evaluate_compliance"]
}