// Entry point for this project's infrastructure.
// This deploys at SUBSCRIPTION scope because our resources are spread across
// several existing resource groups (production app, API app, database) plus
// one brand-new resource group for the free staging environment.
targetScope = 'subscription'

@description('Azure region for newly created resources. Existing resources keep whatever region they already use.')
param location string = 'polandcentral'

@description('Name for the new resource group that will hold the staging environment and the Key Vault.')
param stagingResourceGroupName string = 'rg-webapplication1-staging'

@description('Existing resource group names — do not change unless the real resources move.')
param productionResourceGroupName string = 'DefaultResourceGroup-NEU'
param webapiResourceGroupName string = 'devstudio365-webapi_group'
param sqlResourceGroupName string = 'resource-group-free-SQL-mi-7576739'

@description('Existing resource names — must match exactly what is already deployed.')
param acrName string = 'devstudio35'
param productionPlanName string = 'ASP-DefaultResourceGroupNEU-9492'
param webAppName string = 'web'
param webapiAppName string = 'devstudio365-webapi'
param sqlManagedInstanceName string = 'free-sql-mi-1029307'
param productionDatabaseName string = 'TestDB'
param stagingDatabaseName string = 'StagingDB'

resource stagingRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: stagingResourceGroupName
  location: location
}

// Read-only lookups of the staging apps' CURRENTLY deployed image tags.
// The pipeline (build-and-push.yml) updates these directly on every merge,
// completely outside Bicep. Without reading them here, redeploying this
// Bicep file would reset staging back to a stale hardcoded placeholder,
// undoing whatever the pipeline most recently deployed — exactly the
// regression `what-if` caught. By reading and re-asserting the current
// value instead of a fixed one, infrastructure changes never fight with
// what the pipeline owns.
resource webStagingExisting 'Microsoft.Web/sites@2022-03-01' existing = {
  name: 'web-webapplication1-staging'
  scope: stagingRg
}

resource webapiStagingExisting 'Microsoft.Web/sites@2022-03-01' existing = {
  name: 'webapi-webapplication1-staging'
  scope: stagingRg
}

// ---- Existing resources, referenced read-only so Bicep documents them ----
// without risking any change to what's already live in production.

module acr 'modules/existing-acr.bicep' = {
  name: 'existing-acr'
  scope: resourceGroup(productionResourceGroupName)
  params: {
    acrName: acrName
  }
}

module production 'modules/existing-production.bicep' = {
  name: 'existing-production'
  scope: resourceGroup(productionResourceGroupName)
  params: {
    planName: productionPlanName
    webAppName: webAppName
  }
}

module webapi 'modules/existing-webapi.bicep' = {
  name: 'existing-webapi'
  scope: resourceGroup(webapiResourceGroupName)
  params: {
    webapiAppName: webapiAppName
  }
}

module sql 'modules/existing-sql.bicep' = {
  name: 'existing-sql-and-staging-db'
  scope: resourceGroup(sqlResourceGroupName)
  params: {
    sqlManagedInstanceName: sqlManagedInstanceName
    productionDatabaseName: productionDatabaseName
    stagingDatabaseName: stagingDatabaseName
    location: location
  }
}

// ---- New resources ----

module staging 'modules/staging.bicep' = {
  name: 'staging-environment'
  scope: stagingRg
  params: {
    location: location
    acrLoginServer: acr.outputs.loginServer
    currentWebLinuxFxVersion: webStagingExisting.properties.siteConfig.linuxFxVersion
    currentWebapiLinuxFxVersion: webapiStagingExisting.properties.siteConfig.linuxFxVersion
  }
}

module acrAccess 'modules/acr-role-assignments.bicep' = {
  name: 'acr-role-assignments'
  scope: resourceGroup(productionResourceGroupName)
  params: {
    acrName: acrName
    principalIds: [
      staging.outputs.webStagingPrincipalId
      staging.outputs.webapiStagingPrincipalId
    ]
  }
}

module keyVault 'modules/keyvault.bicep' = {
  name: 'shared-key-vault'
  scope: stagingRg
  params: {
    location: location
  }
}

module productionAppInsights 'modules/production-appinsights.bicep' = {
  name: 'production-app-insights'
  scope: resourceGroup(productionResourceGroupName)
  params: {
    location: location
  }
}

output acrLoginServer string = acr.outputs.loginServer
output productionWebUrl string = production.outputs.defaultHostName
output productionWebapiUrl string = webapi.outputs.defaultHostName
output stagingWebUrl string = staging.outputs.webStagingHostName
output stagingWebapiUrl string = staging.outputs.webapiStagingHostName
output stagingDatabaseId string = sql.outputs.stagingDatabaseId
output keyVaultName string = keyVault.outputs.vaultName
output keyVaultUri string = keyVault.outputs.vaultUri
output productionAppInsightsConnectionString string = productionAppInsights.outputs.connectionString
