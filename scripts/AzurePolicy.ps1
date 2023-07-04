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
                -SubscriptionId $scope
            }
            Default {
                Write-Output "Cant run CreateDefinition to $policyName"
            }
        }
    }
    catch {
        Write-Output "Something went wrong"
    }
}

function CreateAssignment{
    param(
        [Parameter()]
        [string]
        [ValidateSet("policy", "initiative")]
        $type,
        [Parameter()]
        [string]
        $policyName,
        [Parameter()]
        [string]
        $location

    )
    try {
        switch ($type) {
            "policy" { 
                $policyDefinition = Get-AzPolicyDefinition -Name $policyName
                New-AzPolicyAssignment -Name $policyName `
                    -PolicyDefinition $policyDefinition `
                    -Scope "/subscriptions/$scope" `
                    -IdentityType 'SystemAssigned' `
                    -Location $location
            }
            "initiative" { 
                New-AzPolicyDefinition -Name $policyName `
                -Policy $policyFile `
                -SubscriptionId $scope
            }
            Default {
                Write-Output "Cant run CreateAssignment to $policyName"
            }
        }
    }
    catch {
        Write-Output "Something went wrong"
    }
}

#List of policy definitions
$policyDefinitions = @(
    [pscustomobject]@{
        name             = "inherit-rg-tags"
        skip_remediation = false
        file_name        = "Inherit Tags from Resource Group"
        location         = "eastus"
        category         = "Tags"
        type             = "policy"
    },
    [pscustomobject]@{
        name             = "diagnostic-settings-key-vaults"
        file_name        = "Diagnostic Settings Key Vaults"
        location         = "eastus"
        category         = "Monitoring"
        type             = "initiative"
    },
    [pscustomobject]@{
        name             = "diagnostic-settings-azure-functions"
        file_name        = "Diagnostic Settings Azure Functions"
        location         = "eastus"
        category         = "Monitoring"
        type             = "initiative"
    }
)

$initiativeDefinitions = @(
    [pscustomobject]@{
        initiative_name         = "configure_diagnostic_initiative"
        initiative_display_name = "Configure Diagnostic Settings"
        initiative_category     = "Monitoring"
        initiative_description  = "Deploys and configures Diagnostice Settings"
        definitions             = @("diagnostic-settings-key-vaults", "diagnostic-settings-azure-functions")
        assignment_effect       = "DeployIfNotExists"
    }
)

foreach($policy in $policyDefinitions){
    $filePath = "../policies/$($policy.category)/$($policy.file_name).json"
    CreateDefinition -policyName $policy.file_name -policyFile $filePath
    if($policy.type -eq "policy"){
        CreateAssignment -type $policy.type -policyName $policy.file_name -location $policy.location
    }
}
if($initiativeDefinitions.Length -gt 0){
    foreach($initiative in $initiativeDefinitions){
        $initiativePolicies = @()
        foreach($definition in $policyDefinitions){
            if($initiative.definitions -contains $definition.name){
                $initiativePolicies += [pscustomobject]@{
                    "policyDefinitionId" = (Get-AzPolicyDefinition -Name $definition.file_name).PolicyDefinitionId
                }
            }
        }
        $initiativePolicyFile = "../tmp/$($initiative.initiative_name).json"
        $initiativePolicies | ConvertTo-Json -depth 100 | Out-File $initiativePolicyFile
        New-AzPolicySetDefinition -Name "$($initiative.initiative_display_name)" `
            -PolicyDefinition $initiativePolicyFile `
            -Description "$($initiative.initiative_description)" `
            -Metadata '{"category":"<<category>>"}'.Replace('<<category>>', $initiative.initiative_category) `
            -Parameter "../initiatives/$($initiative.initiative_display_name)/parameters.json"
        #CreateAssignment -type "initiative" -policyName $policy.file_name -location $policyLocation
        Remove-Item -Path $initiativePolicyFile
    }
}