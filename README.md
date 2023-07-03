# Policy as code

Repository that contains a list of policies created and implemented in my current Azure tenant.

It was created modules to handle the deployment over subscriptions and management groups. Also it was used an existing module that is mentioned below to test the deployment of policies.

A github action was also implemented to perform the CI/CD of the deployment.

## Repo Folder Structure

```bash
📂.github
  └──📂actions
      └──📂azure-backend
          └──📜action.yaml
      └──📂terraform-apply
          └──📜action.yaml
      └──📂terraform-plan
          └──📜action.yaml
  └──📂workflows
      ├──📜terraform-deploy-old.yml
      └──📜terraform-deploy.yml
📂policies
  └──📂General
      └──📜Enforce Resource Group ReadOnly Lock.json
  └──📂Monitoring
      ├──📜Centralized Log Analytics Workspace.json
      ├──📜Deny Creation New Log Analytics Workspaces.json
      ├──📜Diagnostic Settings Azure Functions.json
      ├──📜Diagnostic Settings Key Vaults.json
      └──📜Diagnostic Settings Storage Account.json
  └──📂Tags
      ├──📜Audit Resource Group Tags.json
      ├──📜Audit Subscription Tags.json
      └──📜Inherit Tags from Resource Group.json
📂terraform-main
  ├──📜main.tf
  ├──📜outputs.tf
  └──📜variables.tf
📂terraform-modules
  └──📂policy-subscription-file
      ├──📜main.tf
      ├──📜outputs.tf
      └──📜variables.tf
```

## Modules

- policy-subscription-file:
  - Deploy the policy using a JSON file as reference. The file must be place in the `policy` folder and the `ENV.tfvars` file must be declared like this:
  ```terraform
  subscription_policy_rules = [
      {
          name              = "centralized-law" #name of the policy
          create_assignment = true #Create the remediation task
          file_name         = "Centralized_Log_Analytics_Workspace" #name of the file without .json
          location          = "eastus" #Location where it'll be deployed
      }
  ]
  ```
- policy-management-group
  - Under construction...
- [policy-as-code]
  - Using the module available [here](https://registry.terraform.io/modules/gettek/policy-as-code/azurerm/latest)

## Configuration

### Variables

```terraform
policy_definitions = [
  {
    name             = "centralized-law" #short name of the policy name
    skip_remediation = false #manage the remediation task
    file_name        = "Centralized Log Analytics Workspace" #Name of the file
    location         = "eastus" #location where will be deployed
    category         = "Monitoring" #Folder where the policy file is located
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
  }
]
management_group = "management-group" #Add management group name

#If you need to have an initiative populate the following variable
initiative_definitions = [
  {
    initiative_name         = "configure_diagnostic_initiative"
    initiative_display_name = "Configure Diagnostic Settings",
    initiative_category     = "Monitoring",
    initiative_description  = "Deploys and configures Diagnostice Settings"
    merge_effects           = false
    definitions             = ["diagnostic-settings-storage-accounts", "diagnostic-settings-key-vaults", "diagnostic-settings-azure-functions"] #List of policy definitions
    assignment_effect       = "DeployIfNotExists"
    skip_role_assignment    = false
    skip_remediation        = false
    re_evaluate_compliance  = true
  }
]
```

### Plan & Apply

- Create a new file with dev.tfvars and add the values mentioned from the variables
- Run the `terraform plan -var-file=dev.tfvars -out=dev.plan`
- Run the `terraform apply dev.plan`

### GitHub Actions

Add the variables in Github repository settings

- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID
- AZURE_SP
- INFRACOST_API_KEY
