# Parameter help description
param(
    # Parameter help description
    [Parameter(Mandatory)]
    [string]
    [ValidateSet("management-group", "subscriptions")]
    $scopeType,
    [Parameter()]
    [string]
    $scope,
    [Parameter()]
    [string]
    $policyLocation
)

function CreateDefinition {
    param(
        [Parameter()]
        [string]
        $policyName,
        [Parameter()]
        [string]
        $policyFile
    )
    try {
        switch ($scopeType) {
            "management-group" { 
                New-AzPolicyDefinition -Name $policyName `
                    -Policy $policyFile `
                    -ManagementGroupName $scope
            }
            "subscriptions" {
                New-AzPolicyDefinition -Name $policyName `
                    -Policy $policyFile `
                    -SubscriptionId $scope.Split("/")[2]
            }
            Default {
                Write-Output "Cant run CreateDefinition to $policyName"
            }
        }
    }
    catch {
        Write-Output "Something went wrong in CreateDefinition"
        Write-Output $_
    }
}

function CreateAssignment {
    param(
        [Parameter()]
        [string]
        [ValidateSet("policy", "initiative", "builtin")]
        $type,
        [Parameter()]
        [string]
        $policyName,
        [Parameter()]
        [string]
        $location,
        [Parameter()]
        [object]
        $parameterObject 

    )
    try {
        $retryCounter = 0
        switch ($type) {
            "policy" { 
                $policyDefinition = Get-AzPolicyDefinition -Name $policyName
                while (!$policyDefinition -and $retryCounter -le 3) {
                    $policyDefinition = Get-AzPolicyDefinition -Name $policyName
                    $retryCounter += 1
                    Start-Sleep 5
                }
                New-AzPolicyAssignment -Name $policyName `
                    -PolicyDefinition $policyDefinition `
                    -Scope $scope `
                    -IdentityType 'SystemAssigned' `
                    -Location $location
            }
            "initiative" { 
                $initiativeDefinition = Get-AzPolicySetDefinition -Name $policyName
                while (!$initiativeDefinition -and $retryCounter -le 3) {
                    $initiativeDefinition = Get-AzPolicyDefinition -Name $policyName
                    $retryCounter += 1
                    Start-Sleep 5
                }
                New-AzPolicyAssignment -Name $policyName `
                    -PolicySetDefinition $initiativeDefinition `
                    -Scope $scope `
                    -IdentityType 'SystemAssigned' `
                    -Location $location
            }
            "builtin" {
                $Policy = Get-AzPolicyDefinition -BuiltIn | Where-Object { $_.Properties.DisplayName -eq $policyName }
                New-AzPolicyAssignment -Name $policyName -PolicyDefinition $Policy -Scope $scope -PolicyParameterObject $parameterObject
            }
            Default {
                Write-Output "Cant run CreateAssignment to $policyName"
            }
        }
    }
    catch {
        Write-Output "Something went wrong in CreateAssignment"
        Write-Output $_
    }
}

#List of bultin policies
$builtinPolicies = @(
    [pscustomobject]@{
        name        = "allowed-locations"
        displayName = "Allowed locations"
        parameters  = @{'listOfAllowedLocations' = @("eastus", "centralus", "westeurope", "global") }
    }
)

#List of policy definitions
$policyDefinitions = @(
    [pscustomobject]@{
        name      = "centralized-law"
        file_name = "Centralized Log Analytics Workspace"
        location  = "eastus"
        category  = "Monitoring"
        type      = "policy"
    },
    [pscustomobject]@{
        name      = "deny-new-laws"
        file_name = "Deny Creation New Log Analytics Workspace"
        location  = "eastus"
        category  = "Monitoring"
        type      = "policy"
    },
    [pscustomobject]@{
        name      = "enforce-rg-tags"
        file_name = "Audit Resource Group Tags"
        location  = "eastus"
        category  = "Tags"
        type      = "policy"
    },
    [pscustomobject]@{
        name      = "inherit-rg-tags"
        file_name = "Inherit Tags from Resource Group"
        location  = "eastus"
        category  = "Tags"
        type      = "policy"
    },
    [pscustomobject]@{
        name      = "enforce-readonly-lock"
        file_name = "Enforce Resource Group ReadOnly Lock"
        location  = "eastus"
        category  = "General"
        type      = "policy"
    },
    [pscustomobject]@{
        name      = "enforce-sub-tags"
        file_name = "Audit Subscription Tags"
        location  = "eastus"
        category  = "Tags"
        type      = "policy"
    },
    [pscustomobject]@{
        name      = "diagnostic-settings-storage-accounts"
        file_name = "Diagnostic Settings Storage Account"
        location  = "eastus"
        category  = "Monitoring"
        type      = "initiative"
    },
    [pscustomobject]@{
        name      = "diagnostic-settings-key-vaults"
        file_name = "Diagnostic Settings Key Vaults"
        location  = "eastus"
        category  = "Monitoring"
        type      = "initiative"
    },
    [pscustomobject]@{
        name      = "diagnostic-settings-azure-functions"
        file_name = "Diagnostic Settings Azure Functions"
        location  = "eastus"
        category  = "Monitoring"
        type      = "initiative"
    }
    [pscustomobject]@{
        name        = "allowed-locations"
        displayName = "Allowed locations"
        parameters  = @{'listOfAllowedLocations' = @("eastus", "centralus", "westeurope", "global") }
        type        = "builtin"
    }
)

$initiativeDefinitions = @(
    [pscustomobject]@{
        initiative_name         = "configure_diagnostic_initiative"
        initiative_display_name = "Configure Diagnostic Settings"
        initiative_category     = "Monitoring"
        initiative_description  = "Deploys and configures Diagnostice Settings"
        definitions             = @("diagnostic-settings-storage-accounts", "diagnostic-settings-key-vaults", "diagnostic-settings-azure-functions")
        assignment_effect       = "DeployIfNotExists"
        location                = "eastus"
    }
)

foreach ($policy in $policyDefinitions) {
    if ($policy.type -eq "builtin") {
        CreateAssignment -type $policy.type -policyName $policy.displayName -parameterObject $policy.parameters
    }
    else {
        $filePath = "./policies/$($policy.category)/$($policy.file_name).json"
        CreateDefinition -policyName $policy.file_name -policyFile $filePath
        if ($policy.type -eq "policy") {
            CreateAssignment -type $policy.type -policyName $policy.file_name -location $policy.location
        }
    }
}
if ($initiativeDefinitions.Length -gt 0) {
    foreach ($initiative in $initiativeDefinitions) {
        $initiativePolicies = @()
        foreach ($definition in $policyDefinitions) {
            if ($initiative.definitions -contains $definition.name) {
                $initiativePolicies += [pscustomobject]@{
                    "policyDefinitionId" = (Get-AzPolicyDefinition -Name $definition.file_name).PolicyDefinitionId
                }
            }
        }

        $initiativePolicyFile = "./tmp/$($initiative.initiative_name).json"
        $initiativePolicies | ConvertTo-Json -depth 100 | Out-File $initiativePolicyFile
        $validateIFPolicyExists = Get-AzPolicySetDefinition -Name $initiative.initiative_display_name
        if (!$validateIFPolicyExists) {
            New-AzPolicySetDefinition -Name "$($initiative.initiative_display_name)" `
                -PolicyDefinition $initiativePolicyFile `
                -Description "$($initiative.initiative_description)" `
                -Metadata '{"category":"<<category>>"}'.Replace('<<category>>', $initiative.initiative_category)
        }

        #Adding this part because of the issue 'UnusedPolicyParameters : The policy set 'Configure Diagnostic Settings' has defined parameters'
        New-AzPolicySetDefinition -Name "$($initiative.initiative_display_name)" `
            -PolicyDefinition $initiativePolicyFile `
            -Description "$($initiative.initiative_description)" `
            -Metadata '{"category":"<<category>>"}'.Replace('<<category>>', $initiative.initiative_category) `
            -Parameter "./initiatives/$($initiative.initiative_display_name)/parameters.json"

        CreateAssignment -type "initiative" -policyName $initiative.initiative_display_name -location $initiative.location

        Remove-Item -Path $initiativePolicyFile
    }
}

$mergeDenitions = $policyDefinitions + $initiativeDefinitions

#Perform a clean up in the Assignments and Custom Definitions 
# $getPolicyAssignment = Get-AzPolicyAssignment -Scope $scope
# if ($scopeType -eq "management-group") {
#     $getPolicyDefinitions = Get-AzPolicyDefinition -Custom -ManagementGroupName $scope
# }
# else {
#     $getPolicyDefinitions = Get-AzPolicyDefinition -Custom -SubscriptionId $scope.Split("/")[2]
# }
# foreach ($policy in $getPolicyDefinitions) {
#     Write-Output "Deployed policy $($policy.Name)"
#     $policyFound = $false
#     foreach ($definedPolicy in $policyDefinitions) {
#         if ($policy.Name -eq $definedPolicy.file_name) {
#             $policyFound = $true
#         }
#     }
#     Write-Output "policyFound $policyFound"
#     Start-Sleep 5
#     # if (!$policyFound) {

#     # }
# }

# foreach ($assignment in $getPolicyAssignment) {
#     Write-Output "Deployed assignment $($assignment.Name)"
#     $assignmentFound = $false
#     foreach ($definition in $mergeDenitions) {
#         if (($assignment.Name -eq $definition.file_name) -or ($assignment.Name -eq $definition.displayName) -or ($assignment.Name -eq $definition.initiative_display_name)) {
#             $assignmentFound = $true
#         }
#     }
#     Write-Output "policyFound $assignmentFound"
#     if (!$assignmentFound) {
#         Remove-AzPolicyAssignment -Name $assignment.Name -Scope $scope -Confirm:$false
#     }
# }