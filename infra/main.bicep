targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))



// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  scope: rg
  name: 'resources'
  params: {
    location: location
    tags: tags
    namingConvention: resourceToken
  }
}

// Executed in the postdeploy hook. See azure.yaml file in the root folder for more info.
// Apps must be deployed before the event grid resources are created.
// module eventGridResources 'eventgridsub.bicep' = {
//   scope: rg
//   name: 'eventGridResources'
//   params: {
//     location: location
//     dataLakeAccountName: resources.outputs.StorageAccName
//     processImageFnName: resources.outputs.UploadImageWebAppName
//     blobExtensionKey: resources.outputs.BlobExtensionKey
//     eventGridTopicName: resources.outputs.EventGridTopicName
//     savePlateFnName: resources.outputs.SavePlateFnName
//   }
//   dependsOn: [
//     resources
//   ]
// }


output DATALAKE_STORAGE_NAME string = resources.outputs.StorageAccName
output PROCESS_IMAGE_FN_NAME string = resources.outputs.ProcessImageFnName
output SAVEPLATE_FN_NAME string = resources.outputs.SavePlateFnName
output EVENTGRID_TOPIC_NAME string = resources.outputs.EventGridTopicName
output RG_NAME string = rg.name

