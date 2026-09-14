# NorthStar Security Operations — Completion Matrix

This matrix distinguishes deployed controls, verified results, authored content, and planned capabilities. NorthStar is controlled portfolio work, not employer production experience.

| Capability | Status | Evidence |
|---|---|---|
| Log Analytics workspace | ✅ Verified | `NorthStar-SOC-Workspace` available in Canada Central with 30-day retention |
| Microsoft Sentinel and Fusion | ✅ Verified | Sentinel solution and built-in Fusion rule enabled |
| Scheduled analytics rules | ✅ Verified | Failed Azure control-plane and Application Gateway WAF detections enabled every five minutes |
| Azure control-plane telemetry | ✅ Verified | Three events matched the deployed failed-operation rule filter |
| Application Gateway WAF telemetry | ✅ Verified | 571 WAF-match events observed from one protected resource |
| Successful role-assignment detection | 🛠️ Authored | MITRE T1098 KQL detection is stored in the repository; deployment validation remains pending |
| Azure RBAC failure hunt | ✅ Verified | MITRE T1098 hunt matched two events from one distinct caller |
| Application Gateway WAF hunt | ✅ Verified | MITRE T1190 hunt validated against aggregate WAF telemetry |
| Incident triage | ✅ Demonstrated | Sanitized RBAC-assignment triage exercise documented as NS-IR-2026-001 |
| Response playbook | ✅ Documented | Manual triage, escalation, and approval-gated containment procedure |
| SOAR automation | 📘 Planned | Sentinel automation rule and Logic App design only; no destructive automation deployed |
| GitHub content validation | ✅ Implemented | Required workflow validates KQL metadata and documentation hygiene |
| Protected main branch | ✅ Implemented | Strict required check, administrator enforcement, linear history, conversation resolution, and destructive-action restrictions |

## Status Definitions

- **Verified** — Confirmed through live Azure or GitHub results.
- **Implemented** — Configured and operating in the project environment.
- **Authored** — Version-controlled content created but not represented as deployed.
- **Demonstrated** — Validated through a controlled portfolio exercise.
- **Documented** — Operational design or procedure recorded without claiming deployment.
- **Planned** — Intentional future work, not yet deployed.
