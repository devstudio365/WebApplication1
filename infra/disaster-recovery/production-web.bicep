// DISASTER RECOVERY ONLY — see acr.bicep for the full explanation.
// Recreates the shared App Service Plan and the production frontend
// (WebApplication1) App Service. Deliberately does NOT declare the custom
// domain (docably.co.uk) or its SSL certificate — provision those yourself
// via the Azure Portal after this runs, if this is ever actually needed.
@description('Region — must match where these resources really live.')
param location string = 'polandcentral'

@description('Login server of the ACR, used to build the container image reference.')
param acrLoginServer string

var planName = 'ASP-DefaultResourceGroupNEU-9492'
var webAppName = 'web'

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: planName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
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
          value: 'https://api.docably.co.uk'
        }
      ]
    }
  }
}

output planId string = plan.id
output webAppPrincipalId string = webApp.identity.principalId
output defaultHostName string = webApp.properties.defaultHostName
