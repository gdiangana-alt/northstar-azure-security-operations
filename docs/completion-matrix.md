# NorthStar Security Operations — Completion Matrix

This matrix distinguishes deployed controls, verified results, authored content, and planned capabilities. NorthStar is controlled portfolio work, not employer production experience.

| Capability | Status | Evidence |
|---|---|---|
| Log Analytics workspace | ✅ Verified | `NorthStar-SOC-Workspace` available in Canada Central with 30-day retention |
| Microsoft Sentinel and Fusion | ✅ Verified | Sentinel solution and built-in Fusion rule enabled |
| Scheduled analytics rules | ✅ Verified | Failed Azure control-plane and high-confidence WAF scanning detections enabled every five minutes; legacy match-all WAF rule disabled |
| Azure control-plane telemetry | ✅ Verified | Three events matched the deployed failed-operation rule filter |
| Application Gateway WAF telemetry | ✅ Verified | 7,404 matches across 347 clients, 842 paths, and 46 rules analyzed over 30 days |
| Successful role-assignment detection | 🛠️ Authored | MITRE T1098 KQL detection is stored in the repository; deployment validation remains pending |
| Azure RBAC failure hunt | ✅ Verified | MITRE T1098 hunt matched two events from one distinct caller |
| Application Gateway WAF hunt | ✅ Verified | MITRE T1190 hunt validated against aggregate WAF telemetry |
| Incident triage | ✅ Demonstrated | Sanitized RBAC-assignment triage exercise documented as NS-IR-2026-001 |
| Approved response playbook | ✅ Verified | Managed-identity Logic App successfully executed after recorded human approval and added an incident comment and `ResponseApproved` label |
| Approval-gated SOAR automation | ✅ Verified | Medium and High incidents become Active, receive `ApprovalRequired`, and get an approval task; a Low-severity negative test was excluded |
| Incident queue remediation | ✅ Verified | 455 legacy WAF incidents classified and closed with telemetry retained; final queue reconciled at 467 Closed, 0 New, and 0 Active |
| GitHub content validation | ✅ Implemented | Required workflow validates KQL metadata and documentation hygiene |
| Operational-state validation | ✅ Verified | Ten Azure and Sentinel checks passed locally and through GitHub Actions using least-privilege OIDC; sanitized JSON evidence uploaded as a workflow artifact |
| Protected main branch | ✅ Implemented | Strict required check, administrator enforcement, linear history, conversation resolution, and destructive-action restrictions |

## Status Definitions

- **Verified** — Confirmed through live Azure or GitHub results.
- **Implemented** — Configured and operating in the project environment.
- **Authored** — Version-controlled content created but not represented as deployed.
- **Demonstrated** — Validated through a controlled portfolio exercise.
- **Documented** — Operational design or procedure recorded without claiming deployment.
- **Planned** — Intentional future work, not yet deployed.
