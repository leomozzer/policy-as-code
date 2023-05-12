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
  └──📂Monitoring
      ├──📜Centralized Log Analytics Workspace.json
      ├──📜Deny Creation New Log Analytics Workspaces.json
      ├──📜Diagnostic Settings Key Vaults.json
      └──📜Diagnostic Settings Storage Account.json
📂terraform-main
  ├──📜main.tf
  ├──📜outputs.tf
  └──📜variables.tf
📂terraform-modules
  └──📂module1
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
policy_rules = [
  {
    name             = "centralized-law" #short name of the policy name
    skip_remediation = false #manage the remediation task
    file_name        = "Centralized Log Analytics Workspace" #Name of the file
    location         = "eastus" #location where will be deployed
    category         = "Monitoring" #Folder where the policy file is located
  }
]
management_group = "management-group" #Add management group name
```

### Plan & Apply

- Create a new file with dev.tfvars and add the values mentioned from the variables
- Run the `terraform plan -var-file=dev.tfvars -out=dev.plan`
- Run the `terraform apply dev.plan`
