# Response Playbooks

NorthStar combines documented manual response procedures with verified Microsoft Sentinel automation and an approval-gated Azure Logic App.

No destructive containment is automated. Medium- and High-severity incidents are prepared automatically, but response execution requires recorded human approval and manual invocation.

## Playbook Catalog

| Playbook | Status | Scope |
|---|---|---|
| [Azure RBAC assignment alert response](azure-rbac-assignment-alert-response.md) | Manual procedure documented | Triage, escalation, containment approval, and recovery |
| [Incident approval automation](../automation/soar/incident-approval-automation.bicep) | Deployed and verified | Activates Medium and High incidents, adds `ApprovalRequired`, and creates an approval task |
| [Approved incident response](../automation/soar/approved-response-playbook.bicep) | Deployed and verified | Manually invoked managed-identity Logic App that records response execution and adds `ResponseApproved` |

## Operating Controls

- Human approval is recorded before response execution.
- Low-severity incidents are excluded from the approval automation.
- The playbook uses a system-assigned managed identity.
- Human, Sentinel service, and playbook permissions are separated.
- Failed execution is detected and investigated.
- No account, session, address, workload, or infrastructure containment is performed automatically.

[View the complete operating model](../docs/sentinel-defender-soar-operating-model.md)
