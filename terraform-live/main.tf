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
    for index, definition in var.policy_definitions : definition.name => definition
  }
  definition       = module.subscription_definition[each.value.name].definition
  assignment_scope = data.azurerm_management_group.management_group.id
  skip_remediation = each.value.skip_remediation
}

### Create Initiatives

locals {
  initiative_list = flatten([
    # for index, definition in var.policy_definitions : {
    #   "name" = definition.name
    #   "definition" = "module.subscription_definition[definition.name].definition"
    # } if definition.type == "initiative"

    for index, initiative in var.initiative_definitions: {
      "initiative": {
        "definitions": [ for definition in var.policy_definitions : module.subscription_definition[definition.name].definition if contains(initiative.definitions, definition.name) == true]
        "initiative_name": initiative.initiative_name
        "initiative_display_name": initiative.initiative_display_name
        "initiative_category": initiative.initiative_category
        "initiative_description": initiative.initiative_description
      }
    }

    # for initiative in var.initiative_definitions : {
    #   "${initiative.initiative_name}": {
    #     "initiative_name" = initiative.initiative_name
    #     "initiative_display_name" = initiative.initiative_display_name
    #     "initiative_category" = initiative.initiative_category
    #     "initiative_description" = initiative.initiative_description
    #     "definitions" = initiative.definitions
    #   }
    # }
    # for index, definition in var.policy_definitions : [
    #   for initiative in var.initiative_definitions : {
    #     "something": {
    #       "bla" = "${initiative.definitions}"
    #     }
    #   }
    #   # [
    #   #   # for item in module.subscription_definition[definition] : [
    #   #   #   item.definition
    #   #   # ]
    #   # ]
    # ] if definition.type == "initiative"
  ])
}

# locals {
#   initiative_list = flatten([
#     for index, initiative in var.initiative_definitions: [
#       for value in local.definitions_list: {
#        "index": index
#        "initiative": initiative
#        "value": value
#       }
#     ]
#   ])
# }

# output "initiative_list" {
#   value = local.initiative_list
# }

# module "definition_initiatives" {
#   source  = "gettek/policy-as-code/azurerm//modules/definition"
#   version = "2.8.0"
#   # for_each = {
#   #   for index, initiative in local.initiative_list : index => initiative
#   # }
#   # policy_name         = each.value["definition"]["file_name"]
#   # display_name        = (jsondecode(file("../policies/${each.value["definition"]["category"]}/${each.value["definition"]["file_name"]}.json"))).properties.displayName
#   # policy_description  = (jsondecode(file("../policies/${each.value["definition"]["category"]}/${each.value["definition"]["file_name"]}.json"))).properties.description
#   # policy_category     = (jsondecode(file("../policies/${each.value["definition"]["category"]}/${each.value["definition"]["file_name"]}.json"))).properties.metadata.category
#   # policy_version      = (jsondecode(file("../policies/${each.value["definition"]["category"]}/${each.value["definition"]["file_name"]}.json"))).properties.metadata.version
#   # management_group_id = data.azurerm_management_group.management_group.id
#   # policy_rule         = (jsondecode(file("../policies/${each.value["definition"]["category"]}/${each.value["definition"]["file_name"]}.json"))).properties.policyRule
#   # policy_parameters   = (jsondecode(file("../policies/${each.value["definition"]["category"]}/${each.value["definition"]["file_name"]}.json"))).properties.parameters
#   # policy_metadata     = (jsondecode(file("../policies/${each.value["definition"]["category"]}/${each.value["definition"]["file_name"]}.json"))).properties.metadata
#   for_each = {
#     for index, initiative in var.initiative_definitions : initiative.initiative_name => initiative
#   }
#   policy_name         = each.value.file_name
#   display_name        = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.displayName
#   policy_description  = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.description
#   policy_category     = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.metadata.category
#   policy_version      = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.metadata.version
#   management_group_id = data.azurerm_management_group.management_group.id
#   policy_rule         = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.policyRule
#   policy_parameters   = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.parameters
#   policy_metadata     = (jsondecode(file("../policies/${each.value.category}/${each.value.file_name}.json"))).properties.metadata
# }

module "configure_initiative" {
  source                  = "gettek/policy-as-code/azurerm//modules/initiative"
  version                 = "2.8.0"
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
