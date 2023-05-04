locals {
  policy = jsondecode(file("../policy/${var.file_name}.json"))
}

resource "azurerm_policy_definition" "policy_definition" {
  name         = var.policy_definition_name
  policy_type  = "Custom"
  mode         = "All"
  display_name = local.policy.properties.displayName
  description  = local.policy.properties.description
  metadata     = tostring(jsonencode(local.policy.properties.metadata))
  policy_rule  = tostring(jsonencode(local.policy.properties.policyRule))
  parameters   = tostring(jsonencode(local.policy.properties.parameters))
}

resource "azurerm_subscription_policy_assignment" "subscription_policy_assignment" {
  count                = var.create_assignment == true ? 1 : 0
  name                 = local.policy.properties.displayName
  policy_definition_id = azurerm_policy_definition.policy_definition.id
  subscription_id      = data.azurerm_subscription.current.id
  identity {
    type = "SystemAssigned"
  }
  location = var.policy_definition_location
}

resource "azurerm_role_assignment" "assignment" {
  count                = var.create_assignment == true ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_subscription_policy_assignment.subscription_policy_assignment[count.index].identity[0].principal_id
}

resource "azurerm_subscription_policy_remediation" "example" {
  count                = var.create_assignment == true ? 1 : 0
  name                 = var.policy_definition_name
  subscription_id      = data.azurerm_subscription.current.id
  policy_assignment_id = azurerm_subscription_policy_assignment.subscription_policy_assignment[count.index].id
}