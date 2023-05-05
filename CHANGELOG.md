# CHANGELOG

## 04-05-2023

Removed the following item due to a limitation in the template. Received errors like "The function 'resourceId' defined in policy is invalid" because when using the function resourceId can't be used when evaluating resources

```json
{
  "field": "Microsoft.Insights/diagnosticSettings/workspaceId",
  "equals": "[contains(concat(parameters('logAnalytics'), '-', parameters('environment')))]"
}
//or
{
  "field": "Microsoft.Insights/diagnosticSettings/workspaceId",
  "equals": "[resourceId(''Microsoft.KeyVault/vaults'', concat(parameters('logAnalytics'), '-', parameters('environment')))]"
}
```

## 05-05-2023

Added the custom module [policy-as-code](https://registry.terraform.io/modules/gettek/policy-as-code/azurerm/latest)
