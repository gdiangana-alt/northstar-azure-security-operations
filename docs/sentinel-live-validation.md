# Sentinel Live Validation

## Objective

Record the Microsoft Sentinel controls verified in the NorthStar Azure environment without exposing tenant, subscription, workspace, or telemetry identifiers.

## Verified Environment

- Log Analytics workspace: `NorthStar-SOC-Workspace`
- Resource group: `NorthStar-Azure-RG`
- Location: Canada Central
- Sentinel solution: enabled
- Log retention: 30 days

## Verified Analytics Rules

| Rule | Status | Severity | Data Source | Frequency | Trigger |
|---|---|---|---|---|---|
| NorthStar - Failed Azure Control Plane Operation | Enabled | Medium | `AzureActivity` | Every 5 minutes | One or more failed control-plane operations |
| NorthStar - Application Gateway WAF Rule Match | Enabled | Low | `AzureDiagnostics` | Every 5 minutes | One or more WAF rule matches |

## Detection Scope

The control-plane rule detects unsuccessful Azure administrative operations in the NorthStar environment. The WAF rule detects Application Gateway firewall matches for analyst triage, distinguishing expected validation traffic from suspicious web requests.

Microsoft Sentinel Fusion is also enabled. No tactic mappings are configured on the two verified scheduled rules at this time.

## Repository Relationship

The repository KQL detection for successful Azure role-assignment creation is authored content mapped to MITRE ATT&CK T1098. It remains validation-pending and is not represented as a deployed Sentinel rule.

## Evidence Integrity

No tenant IDs, subscription IDs, workspace IDs, rule IDs, client IP addresses, request URIs, tokens, or raw event values are included in this document.
