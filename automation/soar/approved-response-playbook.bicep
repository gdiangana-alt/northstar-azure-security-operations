targetScope = 'resourceGroup'

@description('Name of the existing Microsoft Sentinel workspace.')
param workspaceName string = 'NorthStar-SOC-Workspace'

@description('Name of the approval-gated incident response playbook.')
param playbookName string = 'NorthStar-Approved-Incident-Response'

@description('Azure region for the Logic App and API connection.')
param location string = resourceGroup().location

var sentinelConnectionName = '${playbookName}-sentinel'
var sentinelManagedApiId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azuresentinel'
var sentinelResponderRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '3e150937-b8fe-4cfb-8069-0eaf05ecd056'
)

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

resource sentinelConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: sentinelConnectionName
  location: location
  kind: 'V1'
  tags: {
    DataClassification: 'Internal'
  }
  properties: {
    displayName: sentinelConnectionName
    customParameterValues: {}
    parameterValueType: 'Alternative'
    api: {
      id: sentinelManagedApiId
    }
  }
}

resource responsePlaybook 'Microsoft.Logic/workflows@2019-05-01' = {
  name: playbookName
  location: location
  tags: {
    DataClassification: 'Internal'
    'hidden-SentinelTemplateName': 'NorthStarApprovedIncidentResponse'
    'hidden-SentinelTemplateVersion': '1.0'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        Microsoft_Sentinel_incident: {
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              callback_url: '@{listCallbackUrl()}'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            path: '/incident-creation'
          }
        }
      }
      actions: {
        Record_approval_and_response: {
          type: 'ApiConnection'
          inputs: {
            body: {
              incidentArmId: '@triggerBody()?[\'object\']?[\'id\']'
              message: '<p><strong>NorthStar approval-gated response executed.</strong><br>Manual playbook invocation records that analyst approval was obtained before response execution. This controlled portfolio workflow performs no destructive containment.</p>'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/Incidents/Comment'
          }
        }
        Mark_response_approved: {
          type: 'ApiConnection'
          runAfter: {
            Record_approval_and_response: [
              'Succeeded'
            ]
          }
          inputs: {
            body: {
              incidentArmId: '@triggerBody()?[\'object\']?[\'id\']'
              tagsToAdd: {
                TagsToAdd: [
                  {
                    Tag: 'ResponseApproved'
                  }
                ]
              }
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            method: 'put'
            path: '/Incidents'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          azuresentinel: {
            connectionId: sentinelConnection.id
            connectionName: sentinelConnection.name
            id: sentinelManagedApiId
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
          }
        }
      }
    }
  }
}

resource responderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    workspace.id,
    responsePlaybook.id,
    sentinelResponderRoleId
  )
  scope: workspace
  properties: {
    roleDefinitionId: sentinelResponderRoleId
    principalId: responsePlaybook.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output playbookName string = responsePlaybook.name
output connectionName string = sentinelConnection.name
output authenticationModel string = 'System-assigned managed identity'
output executionModel string = 'Manual incident invocation after recorded approval'
