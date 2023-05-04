# 04-05-2023

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
