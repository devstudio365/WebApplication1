// Brand-new staging environment: a Free-tier (F1) App Service Plan hosting
// two Web Apps for Containers. F1 costs €0/month, which is why staging lives
// here instead of on a paid tier.
@description('Azure region for the staging resources.')
param location string

@description('Login server of the existing ACR, e.g. devstudio35.azurecr.io.')
param acrLoginServer string

var planName = 'asp-webapplication1-staging'
var webStagingName = 'web-webapplication1-staging'
var webapiStagingName = 'webapi-webapplication1-staging'

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: planName
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webStaging 'Microsoft.Web/sites@2022-03-01' = {
  name: webStagingName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/webapp:latest'
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'ApiBaseUrl'
          value: 'https://${webapiStagingName}.azurewebsites.net'
        }
      ]
    }
  }
}

resource webapiStaging 'Microsoft.Web/sites@2022-03-01' = {
  name: webapiStagingName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/webapi:latest'
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
    }
  }
}

output webStagingHostName string = webStaging.properties.defaultHostName
output webapiStagingHostName string = webapiStaging.properties.defaultHostName
output webStagingPrincipalId string = webStaging.identity.principalId
output webapiStagingPrincipalId string = webapiStaging.identity.principalId
