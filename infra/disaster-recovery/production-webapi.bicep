// DISASTER RECOVERY ONLY — see acr.bicep for the full explanation.
// Recreates the production API App Service, including its Site Containers
// configuration and its user-assigned managed identity. Deliberately does
// NOT declare the custom domain (api.docably.co.uk) or its SSL certificate —
// provision those yourself via the Azure Portal after this runs, if this is
// ever actually needed.
@description('Region — must match where these resources really live.')
param location string = 'polandcentral'

@description('Login server of the ACR, used to build the container image reference.')
param acrLoginServer string

@description('Resource ID of the shared App Service Plan (created by production-web.bicep).')
param planId string

var webapiAppName = 'devstudio365-webapi'
var identityName = 'ua-id-b8ff'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

resource webapiApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webapiAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    serverFarmId: planId
    siteConfig: {
      linuxFxVersion: 'sitecontainers'
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: identity.properties.clientId
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          // Real value is intentionally NOT stored here — this pulls the real
          // production connection string from the Key Vault secret we already
          // created in Phase 3, never putting the raw secret in this file.
          name: 'ConnectionStrings__DefaultConnection'
          value: '@Microsoft.KeyVault(SecretUri=https://kv-webapp1-avwyklhwnltoi.vault.azure.net/secrets/ProductionDbConnectionString/)'
        }
      ]
    }
  }
}

resource mainContainer 'Microsoft.Web/sites/sitecontainers@2025-03-01' = {
  parent: webapiApp
  name: 'webapi'
  properties: {
    image: '${acrLoginServer}/webapi:latest'
    isMain: true
    targetPort: '8080'
    authType: 'UserAssigned'
    userManagedIdentityClientId: identity.properties.clientId
    inheritAppSettingsAndConnectionStrings: true
  }
}

output identityPrincipalId string = identity.properties.principalId
output identityClientId string = identity.properties.clientId
output defaultHostName string = webapiApp.properties.defaultHostName
