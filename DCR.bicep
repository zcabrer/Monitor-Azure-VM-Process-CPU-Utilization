//DCR Ref: https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep
//VM Association Ref: https://learn.microsoft.com/en-us/azure/azure-monitor/agents/resource-manager-data-collection-rules?tabs=bicep#create-association-with-azure-vm

@description('Name of the data collection rule')
@minLength(1)
param dcrName string = 'TestDCR'

@description('Name of the Log Analytics Workspace')
param workspaceName string = 'demoworkspacezc2'

@description('Log Analytics Workspace Resource Group')
param workspaceRg string = 'rg-demo'

@description('The name of the virtual machine.')
param vmName string = 'DemoVM'

@description('Location')
param location string = resourceGroup().location

@description('The name of the association.')
var associationName = '${vmName}-${dcrName}-association'

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' existing = {
  name: vmName
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = {
  name: associationName
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
    dataCollectionRuleId: dcr.id
  }
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: dcrName
  location: location
  kind: 'Windows'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\Process(*)\\% Processor Time'
          ]
          name: 'perfCounterDataSource60'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: resourceId(workspaceRg, 'Microsoft.OperationalInsights/workspaces', workspaceName)
          name: 'la-data-destination'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Perf'
        ]
        destinations: [
          'la-data-destination'
        ]
      }
    ]
  }
}
