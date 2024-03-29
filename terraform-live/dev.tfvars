policy_definitions = [
  {
    name             = "centralized-law"
    skip_remediation = false
    file_name        = "Centralized Log Analytics Workspace"
    location         = "eastus"
    category         = "Monitoring"
    type             = "policy"
  },
  {
    name             = "deny-new-laws"
    skip_remediation = false
    file_name        = "Deny Creation New Log Analytics Workspace"
    location         = "eastus"
    category         = "Monitoring"
    type             = "policy"
  },
  {
    name             = "enforce-rg-tags"
    skip_remediation = false
    file_name        = "Audit Resource Group Tags"
    location         = "eastus"
    category         = "Tags"
    type             = "policy"
  },
  {
    name             = "inherit-rg-tags"
    skip_remediation = false
    file_name        = "Inherit Tags from Resource Group"
    location         = "eastus"
    category         = "Tags"
    type             = "policy"
  },
  {
    name             = "enforce-readonly-lock"
    skip_remediation = false
    file_name        = "Enforce Resource Group ReadOnly Lock"
    location         = "eastus"
    category         = "General"
    type             = "policy"
  },
  {
    name             = "enforce-sub-tags"
    skip_remediation = false
    file_name        = "Audit Subscription Tags"
    location         = "eastus"
    category         = "Tags"
    type             = "policy"
  },
  {
    name             = "diagnostic-settings-storage-accounts"
    skip_remediation = false
    file_name        = "Diagnostic Settings Storage Account"
    location         = "eastus"
    category         = "Monitoring"
    type             = "initiative"
  },
  {
    name             = "diagnostic-settings-key-vaults"
    skip_remediation = false
    file_name        = "Diagnostic Settings Key Vaults"
    location         = "eastus"
    category         = "Monitoring"
    type             = "initiative"
  },
  {
    name             = "diagnostic-settings-azure-functions"
    skip_remediation = false
    file_name        = "Diagnostic Settings Azure Functions"
    location         = "eastus"
    category         = "Monitoring"
    type             = "initiative"
  },
  {
    name             = "diagnostic-settings-virtual-networks"
    skip_remediation = false
    file_name        = "Diagnostic Settings Virtual Networks"
    location         = "eastus"
    category         = "Monitoring"
    type             = "initiative"
  }
]

initiative_definitions = [
  {
    initiative_name         = "configure_diagnostic_initiative"
    initiative_display_name = "Configure Diagnostic Settings",
    initiative_category     = "Monitoring",
    initiative_description  = "Deploys and configures Diagnostice Settings"
    merge_effects           = false
    definitions             = ["diagnostic-settings-storage-accounts", "diagnostic-settings-key-vaults", "diagnostic-settings-azure-functions", "diagnostic-settings-virtual-networks"]
    assignment_effect       = "DeployIfNotExists"
    skip_role_assignment    = false
    skip_remediation        = false
    re_evaluate_compliance  = true
  }
]
management_group = "lso-management-group"
