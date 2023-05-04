subscription_policy_rules = [
  {
    name              = "centralized-law"
    create_assignment = true
    file_name         = "Centralized_Log_Analytics_Workspace"
    location          = "eastus"
  },
  {
    name              = "diagnostic-settings-storage-accounts"
    create_assignment = true
    file_name         = "Diagnostic_Settings_Storage_Account"
    location          = "eastus"
  },
  {
    name              = "diagnostic-settings-key-vaults"
    create_assignment = true
    file_name         = "Diagnostic_Settings_Key_Vaults"
    location          = "eastus"
  }
]