policy_rules = [
  {
    name              = "centralized-law"
    skip_remediation = false
    file_name         = "Centralized Log Analytics Workspace"
    location          = "eastus"
    category          = "Monitoring"
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
  }
]