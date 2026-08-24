// Read-only reference to the existing production App Service Plan and the
// frontend (WebApplication1) App Service. Both are already live — this module
// only documents them, it does not modify them.
@description('Name of the existing App Service Plan shared by both production apps.')
param planName string

@description('Name of the existing production frontend App Service.')
param webAppName string

resource plan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: planName
}

resource webApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
}

output planId string = plan.id
output defaultHostName string = webApp.properties.defaultHostName
output webAppId string = webApp.id
