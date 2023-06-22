policy_definitions = [
  {
    name             = "centralized-law"
    skip_remediation = false
    file_name        = "Centralized Log Analytics Workspace"
    location         = "eastus"
    category         = "Monitoring"
  },
  {
    name             = "diagnostic-settings-storage-accounts"
    skip_remediation = false
    file_name        = "Diagnostic Settings Storage Account"
    location         = "eastus"
    category         = "Monitoring"
  },
  {
    name             = "diagnostic-settings-key-vaults"
    skip_remediation = false
    file_name        = "Diagnostic Settings Key Vaults"
    location         = "eastus"
    category         = "Monitoring"
  },
  {
    name             = "deny-new-laws"
    skip_remediation = false
    file_name        = "Deny Creation New Log Analytics Workspace"
    location         = "eastus"
    category         = "Monitoring"
  },
  {
    name             = "enforce-rg-tags"
    skip_remediation = false
    file_name        = "Audit Resource Group Tags"
    location         = "eastus"
    category         = "Tags"
  },
  {
    name             = "inherit-rg-tags"
    skip_remediation = false
    file_name        = "Inherit Tags from Resource Group"
    location         = "eastus"
    category         = "Tags"
  },
  {
    name             = "enforce-readonly-lock"
    skip_remediation = false
    file_name        = "Enforce Resource Group ReadOnly Lock"
    location         = "eastus"
    category         = "General"
  },
  {
    name             = "enforce-sub-tags"
    skip_remediation = false
    file_name        = "Audit Subscription Tags"
    location         = "eastus"
    category         = "Tags"
  },
  {
    name             = "diagnostic-settings-azure-functions"
    skip_remediation = false
    file_name        = "Diagnostic Settings Azure Functions"
    location         = "eastus"
    category         = "Monitoring"
  }
]
management_group = "lso-management-group"