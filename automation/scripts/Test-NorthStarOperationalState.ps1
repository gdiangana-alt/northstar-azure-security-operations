[CmdletBinding()]
param(
    [string]$ManifestPath = (
        Join-Path $PSScriptRoot "../config/validation-manifest.yaml"
    ),

    [string]$OutputPath = (
        Join-Path $PSScriptRoot "../../evidence/operational-validation/latest.json"
    )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Validation manifest was not found: $ManifestPath"
}

$pythonCode = @'
import json
import sys
import yaml

with open(sys.argv[1], encoding="utf-8") as manifest_file:
    manifest = yaml.safe_load(manifest_file)

print(json.dumps(manifest))
'@

$manifestJson = & python3 -c $pythonCode $ManifestPath

if ($LASTEXITCODE -ne 0) {
    throw "The YAML manifest could not be parsed."
}

$manifest = $manifestJson | ConvertFrom-Json
function Invoke-AzJson {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $output = & az @Arguments --output json

    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI command failed: az $($Arguments -join ' ')"
    }

    $text = $output -join "`n"

    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }

    return $text | ConvertFrom-Json
}

$checks = [System.Collections.Generic.List[object]]::new()

function Add-ValidationCheck {
    param(
        [string]$Name,
        [object]$Expected,
        [object]$Actual,
        [bool]$Passed
    )

    $checks.Add(
        [pscustomobject]@{
            Name     = $Name
            Expected = $Expected
            Actual   = $Actual
            Passed   = $Passed
        }
    )
}

$subscription = Invoke-AzJson -Arguments @(
    "account",
    "show",
    "--query",
    "{state:state}"
)

Add-ValidationCheck `
    -Name "Azure subscription state" `
    -Expected $manifest.environment.subscription_state `
    -Actual $subscription.state `
    -Passed ($subscription.state -eq $manifest.environment.subscription_state)
$workspace = Invoke-AzJson -Arguments @(
    "monitor",
    "log-analytics",
    "workspace",
    "show",
    "--resource-group",
    $manifest.workspace.resource_group,
    "--workspace-name",
    $manifest.workspace.name,
    "--query",
    "{name:name,resourceGroup:resourceGroup,location:location,retentionInDays:retentionInDays}"
)

$workspaceFound = $null -ne $workspace

Add-ValidationCheck `
    -Name "Log Analytics workspace exists" `
    -Expected "Present" `
    -Actual $(if ($workspaceFound) { "Present" } else { "Missing" }) `
    -Passed $workspaceFound

if ($workspaceFound) {
    Add-ValidationCheck `
        -Name "Workspace resource group" `
        -Expected $manifest.workspace.resource_group `
        -Actual $workspace.resourceGroup `
        -Passed ($workspace.resourceGroup -eq $manifest.workspace.resource_group)

    Add-ValidationCheck `
        -Name "Workspace location" `
        -Expected $manifest.workspace.location `
        -Actual $workspace.location `
        -Passed ($workspace.location -eq $manifest.workspace.location)

    Add-ValidationCheck `
        -Name "Workspace retention" `
        -Expected $manifest.workspace.retention_days `
        -Actual $workspace.retentionInDays `
        -Passed (
            [int]$workspace.retentionInDays -eq
            [int]$manifest.workspace.retention_days
        )
}
$solutions = Invoke-AzJson -Arguments @(
    "resource",
    "list",
    "--resource-group",
    $manifest.workspace.resource_group,
    "--resource-type",
    "Microsoft.OperationsManagement/solutions",
    "--query",
    "[].{name:name}"
)

$sentinelSolution = @($solutions) |
    Where-Object { $_.name -eq $manifest.sentinel.solution_name }

Add-ValidationCheck `
    -Name "Microsoft Sentinel solution" `
    -Expected "Present" `
    -Actual $(if ($sentinelSolution) { "Present" } else { "Missing" }) `
    -Passed ($null -ne $sentinelSolution)
$alertRules = Invoke-AzJson -Arguments @(
    "sentinel",
    "alert-rule",
    "list",
    "--resource-group",
    $manifest.workspace.resource_group,
    "--workspace-name",
    $manifest.workspace.name,
    "--query",
    "[].{displayName:displayName,enabled:enabled,severity:severity,kind:kind}"
)

foreach ($expectedRule in $manifest.sentinel.required_alert_rules) {
    $actualRule = @($alertRules) |
        Where-Object {
            $_.displayName -eq $expectedRule.display_name
        } |
        Select-Object -First 1

    $expectedConfiguration = (
        "Enabled={0}; Kind={1}; Severity={2}" -f
        $expectedRule.enabled,
        $expectedRule.kind,
        $expectedRule.severity
    )

    if ($null -eq $actualRule) {
        Add-ValidationCheck `
            -Name "Sentinel rule: $($expectedRule.display_name)" `
            -Expected $expectedConfiguration `
            -Actual "Missing" `
            -Passed $false

        continue
    }

    $actualConfiguration = (
        "Enabled={0}; Kind={1}; Severity={2}" -f
        $actualRule.enabled,
        $actualRule.kind,
        $actualRule.severity
    )

    $rulePassed = (
        [bool]$actualRule.enabled -eq [bool]$expectedRule.enabled -and
        $actualRule.kind -eq $expectedRule.kind -and
        $actualRule.severity -eq $expectedRule.severity
    )

    Add-ValidationCheck `
        -Name "Sentinel rule: $($expectedRule.display_name)" `
        -Expected $expectedConfiguration `
        -Actual $actualConfiguration `
        -Passed $rulePassed
}
$passedCount = @($checks | Where-Object { $_.Passed }).Count
$failedCount = @($checks | Where-Object { -not $_.Passed }).Count
$overallStatus = if ($failedCount -eq 0) { "Passed" } else { "Failed" }

$result = [ordered]@{
    schema_version = $manifest.schema_version
    generated_utc  = (Get-Date).ToUniversalTime().ToString("o")
    overall_status = $overallStatus

    summary = [ordered]@{
        total_checks  = $checks.Count
        passed_checks = $passedCount
        failed_checks = $failedCount
    }

    target = [ordered]@{
        resource_group = $manifest.workspace.resource_group
        workspace      = $manifest.workspace.name
        location       = $manifest.workspace.location
    }

    checks = $checks
}

$json = $result | ConvertTo-Json -Depth 8

if (
    $manifest.evidence.prohibit_guids -and
    $json -match "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
) {
    throw "Evidence sanitization failed: a GUID was detected."
}

if (
    $manifest.evidence.prohibit_resource_ids -and
    $json -match "/subscriptions/"
) {
    throw "Evidence sanitization failed: an Azure resource ID was detected."
}

$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
Set-Content -LiteralPath $OutputPath -Value $json -Encoding utf8

Write-Host "NorthStar operational-validation result: $overallStatus"
Write-Host "Checks passed: $passedCount/$($checks.Count)"
Write-Host "Sanitized evidence: $OutputPath"
Write-Host ""

$checks |
    Select-Object Name, Passed |
    Format-Table -AutoSize

if ($failedCount -gt 0) {
    exit 1
}
