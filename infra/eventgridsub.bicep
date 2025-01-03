param dataLakeAccountName string
param location string = resourceGroup().location
param processImageFnName string
@secure()
param blobExtensionKey string
param eventGridTopicName string
param savePlateFnName string

resource dataLakeAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: dataLakeAccountName
}

resource eventGridTopic 'Microsoft.EventGrid/topics@2020-06-01' existing = {
  name: eventGridTopicName  
}

resource tollBoothEventsFunctionApp 'Microsoft.Web/sites@2020-09-01' existing = {
  name: savePlateFnName
}

resource blobSystemTopic 'Microsoft.EventGrid/systemTopics@2023-06-01-preview' = {
  name: 'blobTopic'
  location: location
  properties: {
    source: dataLakeAccount.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

resource blobSystemTopicSub 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2023-06-01-preview' = {
  parent: blobSystemTopic
  name: 'blobTopicSubscription'
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: {
        endpointUrl: 'https://${processImageFnName}.azurewebsites.net/runtime/webhooks/blobs?functionName=ProcessImage&code=${blobExtensionKey}'
      }
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
    eventDeliverySchema: 'EventGridSchema'
  }
}

resource eventGridTopicSub 'Microsoft.EventGrid/eventSubscriptions@2023-06-01-preview' = {
  scope: eventGridTopic
  name: 'SAVEPlate'
  properties: {
    destination: {
      endpointType: 'AzureFunction'
      properties: {
        resourceId: '${tollBoothEventsFunctionApp.id}/functions/SavePlateData'
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
    }
    filter: {
      enableAdvancedFilteringOnArrays: true
    }
    eventDeliverySchema: 'EventGridSchema'
  }
}

