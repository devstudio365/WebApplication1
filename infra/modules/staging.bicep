// Brand-new staging environment: a Free-tier (F1) App Service Plan hosting
// two Web Apps for Containers. F1 costs €0/month, which is why staging lives
// here instead of on a paid tier.
@description('Azure region for the staging resources.')
param location string

@description('Login server of the existing ACR, e.g. devstudio35.azurecr.io.')
param acrLoginServer string

@description('The image currently deployed to web-webapplication1-staging, read from the live resource so redeploying infrastructure never resets what the pipeline last deployed.')
param currentWebLinuxFxVersion string

@description('The image currently deployed to webapi-webapplication1-staging, same reasoning as above.')
param currentWebapiLinuxFxVersion string

var planName = 'asp-webapplication1-staging'
var webStagingName = 'web-webapplication1-staging'
var webapiStagingName = 'webapi-webapplication1-staging'

// Log Analytics Workspace is a required prerequisite for the modern
// "workspace-based" Application Insights — free for the first 5GB/month of
// data ingested, which a low-traffic staging environment won't come close to.
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-webapplication1-staging'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-webapplication1-staging'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

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
      linuxFxVersion: currentWebLinuxFxVersion
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
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
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
      linuxFxVersion: currentWebapiLinuxFxVersion
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
          // Real value is intentionally NOT stored here — this pulls the
          // staging connection string from the Key Vault secret created in
          // Phase 3, using webapiStaging's own managed identity (already
          // granted Key Vault Secrets User on that specific secret).
          name: 'ConnectionStrings__DefaultConnection'
          value: '@Microsoft.KeyVault(SecretUri=https://kv-webapp1-avwyklhwnltoi.vault.azure.net/secrets/StagingDbConnectionString/)'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
}

output webStagingHostName string = webStaging.properties.defaultHostName
output webapiStagingHostName string = webapiStaging.properties.defaultHostName
output webStagingPrincipalId string = webStaging.identity.principalId
output webapiStagingPrincipalId string = webapiStaging.identity.principalId
