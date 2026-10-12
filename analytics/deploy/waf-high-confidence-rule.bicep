targetScope = 'resourceGroup'

@description('Existing Log Analytics workspace hosting Microsoft Sentinel.')
param workspaceName string = 'NorthStar-SOC-Workspace'

@description('Controls whether the analytics rule evaluates live telemetry.')
param ruleEnabled bool = true

var detectionQuery = loadTextContent('../detections/application-gateway-waf-high-confidence-scan.kql')

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

resource wafHighConfidenceRule 'Microsoft.SecurityInsights/alertRules@2025-09-01' = {
  name: guid(workspace.id, 'northstar-waf-high-confidence-scanning')
  scope: workspace
  kind: 'Scheduled'
  properties: {
    displayName: 'NorthStar - High-Confidence WAF Scanning Activity'
    description: 'Detects one client generating at least 100 WAF matches across at least 10 rules and 30 request paths within five minutes. Thresholds are based on 30 days of NorthStar telemetry.'
    enabled: ruleEnabled
    severity: 'Medium'
    query: detectionQuery
    queryFrequency: 'PT5M'
    queryPeriod: 'PT5M'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionEnabled: false
    suppressionDuration: 'PT1H'
    tactics: [
      'Reconnaissance'
    ]
    techniques: [
      'T1595'
    ]
    eventGroupingSettings: {
      aggregationKind: 'AlertPerResult'
    }
    entityMappings: [
      {
        entityType: 'IP'
        fieldMappings: [
          {
            identifier: 'Address'
            columnName: 'ClientIp'
          }
        ]
      }
    ]
    customDetails: {
      WafMatches: 'WafMatches'
      DistinctRules: 'DistinctRules'
      DistinctPaths: 'DistinctPaths'
      FirstObserved: 'FirstObserved'
      LastObserved: 'LastObserved'
    }
    alertDetailsOverride: {
      alertDisplayNameFormat: 'High-confidence WAF scanning from {{ClientIp}}'
      alertDescriptionFormat: 'The source generated {{WafMatches}} WAF matches across {{DistinctRules}} rules and {{DistinctPaths}} paths within five minutes.'
    }
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT1H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'IP'
        ]
        groupByAlertDetails: [
          'DisplayName'
        ]
        groupByCustomDetails: []
      }
    }
  }
}
