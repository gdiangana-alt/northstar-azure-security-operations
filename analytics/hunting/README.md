# Threat Hunting

This directory will contain hypothesis-driven KQL queries, investigation notes, expected results, and promotion criteria for converting validated hunts into analytics rules.

## Hunting Catalog

| Hunt | Data Source | MITRE ATT&CK | Validation Status |
|---|---|---|---|
| [Failed Azure role-assignment attempts](failed-role-assignment-attempts.kql) | AzureActivity | T1098 Account Manipulation | Verified: 2 matching events from 1 distinct caller in a 30-day aggregate query |
| [Application Gateway WAF rule matches](application-gateway-waf-matches.kql) | AzureDiagnostics | T1190 Exploit Public-Facing Application | Verified: 571 matching events from one protected resource in a 30-day aggregate query |
