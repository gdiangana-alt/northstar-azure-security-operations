# Detection Analytics

KQL detections include purpose, required data source, MITRE ATT&CK mapping, tuning guidance, and validation status.

| Detection | Data Source | MITRE ATT&CK | Status |
|---|---|---|---|
| [Successful Azure role assignment created](azure-role-assignment-created.kql) | AzureActivity | T1098 Account Manipulation | Authored; validation pending |
| [High-confidence Application Gateway WAF scanning](application-gateway-waf-high-confidence-scan.kql) | AzureDiagnostics | T1595 Active Scanning | Deployed and verified |

## Deployment

The high-confidence WAF rule is deployed through [`waf-high-confidence-rule.bicep`](../deploy/waf-high-confidence-rule.bicep). It was validated while disabled, enabled after configuration verification, and replaced the disabled match-all WAF rule.
