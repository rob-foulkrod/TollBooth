@description('MTT Alias for unique resource names')
@maxLength(13)
param namingConvention string = 'mtt'

@description('Location for all resources')
param location string = resourceGroup().location


param tags object
var abbrs = loadJsonContent('./abbreviations.json')

// 24 character restriction, and keeping the original suffix requires trimming the namingConvention to 11 characters
var dataLakeAccountName = '${abbrs.dataLakeStoreAccounts}${take(namingConvention, 11)}lake'
var dataLakeConnectionSecretName = 'dataLakeConnectionString'
var dataLakeContainers = [
  'images'
  'export'
]
var cosmosDbAccountName = '${abbrs.documentDBDatabaseAccounts}${namingConvention}cosmosdb'
var cosmosDbAuthKeySecretName = 'cosmosDBAuthorizationKey'
var cosmosDbDatabaseId = 'LicensePlates'
var cosmosDbContainerProcessed = 'Processed'
var cosmosDbContainerManual = 'NeedsManualReview'
var tollBoothFunctionAppName = '${abbrs.webSitesFunctions}${namingConvention}tbfunctions'
var tollBoothFunctionsHostingPlanName = '${abbrs.webServerFarms}${namingConvention}tbfunctionsplan'
var tollBoothEventsFunctionAppName = '${abbrs.webSitesFunctions}${namingConvention}tbevents'
var tollBoothEventsHostingPlanName = '${abbrs.webServerFarms}${namingConvention}tbeventsplan'
var imageUploadPlanName = '${abbrs.webServerFarms}${namingConvention}tbimageuploadplan'
var imageUploadWebAppName = '${abbrs.webSitesAppService}${namingConvention}tbimageuploadapp'
var appInsightsName = '${abbrs.insightsComponents}${namingConvention}tbappinsights'
var workspaceName = '${abbrs.operationalInsightsWorkspaces}${namingConvention}tbworkspace'
var eventGridTopicName = '${abbrs.eventGridDomainsTopics}${namingConvention}tbeventgridtopic'
var eventGridTopicKeySecretName = 'eventGridTopicKey'
var cosmosDbConnectionStringSecretName = 'cosmosDbConnectionString'
var computerVisionName = '${abbrs.cognitiveServicesAccounts}${namingConvention}tbcomputervision'
var computerVisionSecretName = 'computerVisionApiKey'
var keyVaultName = '${abbrs.keyVaultVaults}${namingConvention}'
var logicAppName = '${abbrs.logicWorkflows}${namingConvention}'


resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  tags: tags
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableSoftDelete: false
    tenantId: subscription().tenantId
    enableRbacAuthorization: false
    accessPolicies: []
  }

}

resource keyVaultFnAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: reference(tollBoothFunctionApp.id, '2019-08-01', 'Full').identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: reference(tollBoothEventsFunctionApp.id, '2019-08-01', 'Full').identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

resource computerVisionSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: computerVisionSecretName
  properties: {
    value: computerVision.listKeys('2017-04-18').key1
  }
}

resource cosmosDbAuthKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: cosmosDbAuthKeySecretName
  properties: {
    value: cosmosDbAccount.listKeys('2021-01-15').primaryMasterKey
  }
}

resource cosmosDbConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: cosmosDbConnectionStringSecretName
  properties: {
    value: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

resource dataLakeConnectionSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: dataLakeConnectionSecretName
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${dataLakeAccountName};AccountKey=${dataLakeAccount.listKeys('2019-06-01').keys[0].value}'
  }
}

resource eventGridTopicKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: eventGridTopicKeySecretName
  properties: {
    value: eventGridTopic.listKeys('2020-06-01').key1
  }
}

resource dataLakeAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: dataLakeAccountName
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  location: location
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }

}

resource dataLakeAccountBlobService 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
  parent: dataLakeAccount
  name: 'default'
}

resource dataLakeAccountFileService 'Microsoft.Storage/storageAccounts/fileServices@2019-06-01' = {
  parent: dataLakeAccount
  name: 'default'
}

resource dataLakeContainerList 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for item in dataLakeContainers: {
  name: '${dataLakeAccountName}/default/${item}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    dataLakeAccount
    dataLakeAccountBlobService
  ]
}]

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-01-15' = {
  name: cosmosDbAccountName
  tags: tags
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    enableMultipleWriteLocations: false
    networkAclBypass: 'AzureServices'
    publicNetworkAccess: 'Enabled'
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-01-15' = {
  parent: cosmosDbAccount
  name: cosmosDbDatabaseId
  properties: {
    resource: {
      id: cosmosDbDatabaseId
    }
  }
}

resource cosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-01-15' = {
  parent: cosmosDbDatabase
  name: cosmosDbContainerProcessed
  properties: {
    resource: {
      id: cosmosDbContainerProcessed
      partitionKey: {
        paths: [
          '/licensePlateText'
        ]
      }
    }
    options: {
      autoscaleSettings: {
        maxThroughput: 4000
      }
    }
  }
}

resource cosmosDbAccContainerManual 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-01-15' = {
  parent: cosmosDbDatabase
  name: cosmosDbContainerManual
  properties: {
    resource: {
      id: cosmosDbContainerManual
      partitionKey: {
        paths: [
          '/fileName'
        ]
      }
    }
    options: {
      autoscaleSettings: {
        maxThroughput: 4000
      }
    }
  }
}

resource eventGridTopic 'Microsoft.EventGrid/topics@2020-06-01' = {
  name: eventGridTopicName
  location: location
  properties: {
    inputSchema: 'EventGridSchema'
  }
}

resource logicApp 'Microsoft.Logic/workflows@2016-06-01' = {
  name: logicAppName
  location: location
  properties: {
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      actions: {}
      triggers: {}
      outputs: {}
    }
    parameters: {}
  }
}

// resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
//   name: appInsightsName
//   tags: tags
//   location: location
//   kind: 'web'
//   properties: {
//     Application_Type: 'web'
//   }
// }

module monitoring 'br/public:avm/ptn/azd/monitoring:0.1.0' = {
  name: 'monitoring'
  params: {
    logAnalyticsName: workspaceName
    applicationInsightsName: appInsightsName
    applicationInsightsDashboardName: '${appInsightsName}dash'
    location: location
    tags: tags
  }
}


resource tollBoothFunctionsHostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: tollBoothFunctionsHostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource tollBoothFunctionApp 'Microsoft.Web/sites@2020-09-01' = {
  name: tollBoothFunctionAppName
  tags: union(tags, { 'azd-service-name': 'fastcardev-tollboothfunction' })
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: tollBoothFunctionsHostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${dataLakeAccountName};AccountKey=${dataLakeAccount.listKeys('2019-06-01').keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${dataLakeAccountName};AccountKey=${dataLakeAccount.listKeys('2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: '${dataLakeAccountName}functions'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: monitoring.outputs.applicationInsightsInstrumentationKey
        }
        {
          name: 'computerVisionApiUrl'
          value: '${computerVision.properties.endpoint}vision/v3.0/ocr'
        }
        {
          name: 'computerVisionApiKey'
          value: '@Microsoft.KeyVault(SecretUri=${computerVisionSecret.properties.secretUriWithVersion})'
        }
        {
          name: 'cosmosDBEndpointUrl'
          value: cosmosDbAccount.properties.documentEndpoint
        }
        {
          name: 'cosmosDBAuthorizationKey'
          value: '@Microsoft.KeyVault(SecretUri=${cosmosDbAuthKeySecret.properties.secretUriWithVersion})'
        }
        {
          name: 'cosmosDBDatabaseId'
          value: cosmosDbDatabaseId
        }
        {
          name: 'cosmosDBCollectionId'
          value: cosmosDbContainerProcessed
        }
        {
          name: 'dataLakeConnection'
          value: '@Microsoft.KeyVault(SecretUri=${dataLakeConnectionSecret.properties.secretUriWithVersion})'
        }
        {
          name: 'eventGridTopicEndpoint'
          value: eventGridTopic.properties.endpoint
        }
        {
          name: 'eventGridTopicKey'
          value: '@Microsoft.KeyVault(SecretUri=${eventGridTopicKeySecret.properties.secretUriWithVersion})'
        }
        {
          name: 'exportCsvContainerName'
          value: 'export'
        }
      ]
    }
    clientAffinityEnabled: false
    reserved: false
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource tollBoothEventsHostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: tollBoothEventsHostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource tollBoothEventsFunctionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: tollBoothEventsFunctionAppName
  tags: union(tags, { 'azd-service-name': 'fastcardev-saveplatedatafunction' })
  location: location
  kind: 'functionapp'
  
  properties: {
    serverFarmId: tollBoothEventsHostingPlan.id
    
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${dataLakeAccountName};AccountKey=${dataLakeAccount.listKeys('2019-06-01').keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${dataLakeAccountName};AccountKey=${dataLakeAccount.listKeys('2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: '${dataLakeAccountName}events'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: monitoring.outputs.applicationInsightsInstrumentationKey
        }
        {
          name: 'cosmosDBConnection'
          value: '@Microsoft.KeyVault(SecretUri=${cosmosDbConnectionStringSecret.properties.secretUriWithVersion})'
        }
      ]
    }
    clientAffinityEnabled: false
    reserved: false
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource imageUploadPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: imageUploadPlanName
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource imageUploadWebApp 'Microsoft.Web/sites@2021-01-15' = {
  name: imageUploadWebAppName
  tags: union(tags, { 'azd-service-name': 'fastcardev-uploadimage' })
  location: location
  properties: {
    serverFarmId: imageUploadPlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|6.0'
      appSettings: [
        {
          name: 'AzureStorage__Name'
          value: dataLakeAccountName
        }
        {
          name: 'AzureStorage__ContainerName'
          value: dataLakeContainers[0]
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource blobContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(resourceGroup().id, dataLakeAccount.name, blobContributorRoleDefinition.id)
  properties: {
    roleDefinitionId: blobContributorRoleDefinition.id
    principalId: imageUploadWebApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource computerVision 'Microsoft.CognitiveServices/accounts@2017-04-18' = {
  name: computerVisionName
  sku: {
    name: 'S1'
  }
  location: location
  kind: 'ComputerVision'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

output ComputerVisionEndpoint string = '${computerVision.properties.endpoint}vision/v3.0/ocr'
output CosmosDbEndpoint string = cosmosDbAccount.properties.documentEndpoint
output EventGridTopicEndpoint string = eventGridTopic.properties.endpoint
output ComputerVisionKeySecretUri string = computerVisionSecret.properties.secretUriWithVersion
output CosmosDbAuthKeySecretUri string = cosmosDbAuthKeySecret.properties.secretUriWithVersion
output DataLakeConnectionSecretUri string = dataLakeConnectionSecret.properties.secretUriWithVersion
output EventGridTopicKeySecretUri string = eventGridTopicKeySecret.properties.secretUriWithVersion
output ProcessImageFnName string = tollBoothFunctionAppName
output SavePlateFnName string = tollBoothEventsFunctionAppName
output EventGridTopicName string = eventGridTopicName
output StorageAccName string = dataLakeAccountName
output UploadImageWebAppName string = imageUploadWebAppName
