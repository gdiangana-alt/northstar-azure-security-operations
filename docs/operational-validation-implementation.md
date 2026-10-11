# NorthStar Operational Validation Implementation

**Implementation date:** October 11, 2026
**Status:** Implemented and locally validated; GitHub-hosted validation pending merge

## Executive Summary

NorthStar now includes a PowerShell-based operational validator that compares the live Azure and Microsoft Sentinel environment with a version-controlled YAML policy.

The validator performs read-only checks, identifies configuration drift, produces sanitized JSON evidence, and returns an exit code that can pass or fail a GitHub Actions workflow.

## Problem Addressed

The repository previously documented live Sentinel controls, but verifying them required separate manual Azure CLI commands. Manual validation is slower, inconsistent, and difficult to integrate into CI/CD.

The new capability converts those checks into one repeatable control.

## Architecture

1. `validation-manifest.yaml` defines the approved operational state.
2. `Test-NorthStarOperationalState.ps1` queries Azure and Sentinel.
3. The script compares expected and actual values.
4. Sanitized results are written to JSON.
5. Any failed check returns exit code `1`.
6. GitHub Actions authenticates to Azure through OIDC.
7. The workflow uploads the JSON report as a temporary artifact.

## Validated Controls

The implementation verifies:

- Azure subscription state
- Log Analytics workspace existence
- Workspace resource group
- Workspace region
- Workspace retention
- Microsoft Sentinel enablement
- Fusion rule status, kind, and severity
- Failed Azure control-plane rule status, kind, and severity
- Application Gateway WAF rule status, kind, and severity

## Security Design

### Read-only runtime

The validator only queries Azure resource metadata. It does not create, update, disable, contain, or delete operational resources.

### Least-privilege identity

The existing DevSecOps managed identity was evaluated and rejected for reuse because it also held `Storage Blob Data Contributor`. That permission was unnecessary for operational validation.

A dedicated `northstar-soc-validator` managed identity was created with only `Reader` access scoped to `NorthStar-Azure-RG`.

### Passwordless authentication

GitHub Actions uses OpenID Connect to request a short-lived Azure token. No client secret, password, certificate, or reusable token is stored in GitHub.

The federated credential is restricted to the security-operations repository and its `main` branch.

### Evidence sanitization

Generated evidence is rejected if it contains:

- GUID-formatted identifiers
- Azure resource IDs beginning with `/subscriptions/`

The committed report contains operational metadata only.

## Azure Policy Enforcement

The first managed-identity creation attempt was denied by Azure Policy because the resource did not include the mandatory `DataClassification=Internal` tag.

No noncompliant resource was created.

The deployment was corrected by including the required classification tag, after which Azure accepted the resource.

This demonstrates that NorthStar governance controls are enforced during deployment rather than merely documented.

## Validation Results

### Positive test

The validator checked the live NorthStar environment and reported:

- Total checks: 9
- Passed checks: 9
- Failed checks: 0
- Exit code: 0

### Controlled negative test

A temporary manifest changed the expected workspace retention from 30 to 31 days. Azure itself was not modified.

The validator reported:

- Total checks: 9
- Passed checks: 8
- Failed checks: 1
- Failed control: workspace retention
- Exit code: 1

This proved that the automation detects drift and can stop a CI/CD workflow.

## Operational Value

This capability reduces reliance on manual portal checks and creates a consistent, reviewable record of operational security state. It also provides a foundation for adding further controls such as data-connector health, analytics-rule scheduling, incident metrics, and approved SOAR automation.

## Simple Explanation

I defined what a healthy Sentinel environment should look like in a YAML file. I then built a PowerShell script that checks Azure against that policy. If everything matches, it produces a clean JSON report and succeeds. If something is missing or changed, it identifies the mismatch and fails the pipeline.

## Recruiter Explanation

I implemented policy-driven operational validation for an Azure Sentinel lab. I separated expected state from execution logic, used PowerShell and Azure CLI for read-only checks, added sanitized JSON evidence, and proved drift detection with both positive and negative tests. For CI/CD, I designed passwordless GitHub-to-Azure authentication using OIDC and a dedicated managed identity with resource-group-scoped Reader access. I also encountered an Azure Policy denial for a missing data-classification tag and corrected the deployment to comply with governance requirements.
