targetScope = 'resourceGroup'

@description('Existing Log Analytics workspace hosting Microsoft Sentinel.')
param workspaceName string = 'NorthStar-SOC-Workspace'

@description('Controls whether the incident-triage automation rule is enabled.')
param automationEnabled bool = false

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

resource approvalAutomation 'Microsoft.SecurityInsights/automationRules@2025-09-01' = {
  name: guid(workspace.id, 'northstar-approval-required-triage')
  scope: workspace
  properties: {
    displayName: 'NorthStar - Require Approval for Medium and High Incidents'
    order: 100
    triggeringLogic: {
      isEnabled: automationEnabled
      expirationTimeUtc: '9999-12-31T23:59:59Z'
      triggersOn: 'Incidents'
      triggersWhen: 'Created'
      conditions: [
        {
          conditionType: 'Property'
          conditionProperties: {
            propertyName: 'IncidentSeverity'
            operator: 'Equals'
            propertyValues: [
              'Medium'
              'High'
            ]
          }
        }
      ]
    }
    actions: [
      {
        order: 1
        actionType: 'ModifyProperties'
        actionConfiguration: {
          status: 'Active'
          labels: [
            {
              labelName: 'ApprovalRequired'
            }
          ]
        }
      }
      {
        order: 2
        actionType: 'AddIncidentTask'
        actionConfiguration: {
          title: 'Obtain approval before containment'
          description: 'Validate scope, business impact, evidence, rollback, and approver identity. Run the response playbook manually only after approval is recorded.'
        }
      }
    ]
  }
}
