# NS-IR-2026-001 — Failed Azure RBAC Assignment Attempt Triage

## Incident Record

| Field | Value |
|---|---|
| Incident ID | NS-IR-2026-001 |
| Severity | Informational |
| Status | Closed — triage exercise |
| Detection source | AzureActivity hunting query |
| Analysis window | September 9–13, 2026 UTC |
| Incident owner | NorthStar security operations |

## Executive Summary

A sanitized aggregate hunt identified two failed Azure RBAC role-assignment operations associated with one distinct caller during the analysis window. The events were reviewed as a controlled portfolio triage exercise. No raw event records, caller identities, resource identifiers, or credentials were retained in this repository.

The aggregate result alone does not establish malicious intent. The record therefore documents the analyst decision process rather than representing a confirmed security incident.

## Detection and Triage

- Hunt: [`failed-role-assignment-attempts.kql`](../analytics/hunting/failed-role-assignment-attempts.kql)
- Detection hypothesis: failed RBAC-assignment operations can indicate an authorization misconfiguration or an attempted privilege change.
- Aggregate finding: 2 matching failures from 1 distinct caller.
- Triage decision: closed as an informational exercise; no containment action was justified from aggregate evidence alone.

## MITRE ATT&CK Mapping

| Tactic | Technique | ID | Rationale |
|---|---|---|---|
| Privilege Escalation | Account Manipulation | T1098 | Role-assignment changes can modify cloud authorization. |

## Investigation Timeline

| UTC Time | Event | Analyst Action | Evidence |
|---|---|---|---|
| September 9–13, 2026 | Failed role-assignment operations observed | Ran a sanitized aggregate KQL hunt | 2 events; 1 distinct caller |
| Triage completion | No attribution or intent determined from aggregate data | Closed as informational | No raw data published |

## Response and Follow-Up

- No automated containment was executed.
- In a production investigation, analysts would correlate the private raw events with approved change records and examine related successful role-assignment activity.
- Unexpected callers or repeated failures would be escalated for identity and authorization review.
- The validated hunt remains available for recurring investigation.

## Evidence Handling

This report contains aggregate counts only. It excludes personal identities, client IP addresses, resource IDs, correlation IDs, request content, subscriptions, tenant information, and authentication material.
