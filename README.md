# Policy as code

Repository that contains a list of policies created and implemented in my current Azure tenant.

It was created modules to handle the deployment over subscriptions and management groups.

A github action was also implemented to perform the CI/CD of the deployment

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
