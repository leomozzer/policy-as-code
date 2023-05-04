module "subscription_policy" {
  source = "../terraform-modules/policy-subscription-file"
  for_each = {
    for index, policy in var.subscription_policy_rules : policy.name => policy
  }
  policy_definition_name     = each.value.name
  create_assignment          = each.value.create_assignment
  file_name                  = each.value.file_name
  policy_definition_location = each.value.location
}