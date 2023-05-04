resource "azurerm_policy_definition" "policy_definition" {
  name         = var.policy_definition_name
  policy_type  = "Custom"
  mode         = "All"
  display_name = var.policy_definition_display_name
  description  = var.policy_definition_description
  metadata     = var.policy_definition_metadata
  policy_rule  = var.policy_definition_policy_rule
  parameters   = var.policy_definition_parameters
}

resource "azurerm_subscription_policy_assignment" "subscription_policy_assignment" {
  count                = var.create_assignment == true ? 1 : 0
  name                 = var.policy_definition_display_name
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