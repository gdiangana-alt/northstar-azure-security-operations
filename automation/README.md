# NorthStar Operational Validation Automation

## Purpose

This automation performs read-only validation of the live NorthStar Azure security-operations environment against a version-controlled expected-state manifest.

It detects configuration drift, produces sanitized JSON evidence, and returns a non-zero exit code when a required control is missing or misconfigured.

## Validated Controls

The runner verifies:

1. The Azure subscription is enabled.
2. The Log Analytics workspace exists.
3. The workspace is in the expected resource group and region.
4. Workspace retention matches the approved value.
5. Microsoft Sentinel is enabled.
6. Fusion is enabled with the expected severity.
7. The failed Azure control-plane analytics rule is enabled.
8. The Application Gateway WAF analytics rule is enabled.
9. Required Sentinel rule kinds and severities match policy.

## Components

- `config/validation-manifest.yaml` defines the expected operational state.
- `scripts/Test-NorthStarOperationalState.ps1` performs live read-only checks.
- `../evidence/operational-validation/latest.json` records sanitized results.

## Run Locally

Prerequisites:

- Azure CLI authenticated to the intended subscription
- PowerShell 7
- Python 3 with PyYAML
- Read access to the target Azure and Sentinel resources

Run:

```bash
pwsh -NoProfile -File automation/scripts/Test-NorthStarOperationalState.ps1

```

A successful run returns exit code `0`. Detected drift returns exit code `1`.

## Security Controls

The automation:

- Uses read-only Azure queries.
- Does not create, update, disable, or delete Azure resources.
- Does not publish credentials or authentication tokens.
- Rejects evidence containing GUIDs or Azure resource IDs.
- Stores only operational metadata required for validation.
- Separates expected policy from executable validation logic.

## Negative Test

A controlled test changed the expected retention value from 30 to 31 days in a temporary manifest. The validator detected the mismatch, reported one failed check, and returned exit code `1`. No Azure configuration was changed.

## Portfolio Scope

This is controlled NorthStar portfolio work. It demonstrates operational-validation design, PowerShell automation, Azure CLI integration, configuration-drift detection, evidence sanitization, and CI/CD readiness. It does not represent employer production activity.
