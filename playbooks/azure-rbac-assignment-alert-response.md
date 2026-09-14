# Azure RBAC Assignment Alert Response Playbook

## Purpose

Provide a repeatable analyst procedure for investigating successful or failed Azure RBAC role-assignment activity. The procedure supports the NorthStar role-assignment detection and validated hunting queries.

## Trigger Conditions

- Successful Azure role-assignment creation detected
- Failed Azure role-assignment attempt identified during a hunt
- Repeated or unexpected authorization-change activity

## Triage Procedure

1. Confirm the event time, operation type, target scope, caller, and result in the private Sentinel investigation context.
2. Correlate the activity with an approved change record or deployment workflow.
3. Determine whether the requested role and scope follow least-privilege requirements.
4. Review nearby successful role-assignment operations and related identity events.
5. Classify the event as expected, misconfiguration, suspicious, or confirmed unauthorized activity.

## Decision Matrix

| Finding | Analyst Action | Escalation |
|---|---|---|
| Approved change with least-privilege scope | Document and close | None |
| Failed request caused by configuration error | Notify change owner; correct through approved change process | Infrastructure or IAM owner |
| Unexpected request or excessive scope | Preserve evidence and escalate | Security and IAM owner |
| Confirmed unauthorized assignment | Start incident response and request approved containment | Security incident lead |

## Containment Boundary

No automatic role removal, account disablement, or permission change is performed by this repository. Containment requires authorized human approval because an incorrect action could interrupt a legitimate deployment or administrative task.

## Future SOAR Design

A future Microsoft Sentinel automation rule and Logic App could:

1. tag the incident as `rbac-change`;
2. enrich it with approved-change metadata;
3. notify the security and IAM teams; and
4. create an approval task for a human containment decision.

The design intentionally stops before any destructive action. Automatic role removal would require separate authorization, tested rollback, and narrowly scoped permissions.

## Evidence Handling

Publish only sanitized aggregate findings. Keep caller identities, resource IDs, correlation IDs, role details, incident URLs, and raw events inside the authorized investigation environment.
