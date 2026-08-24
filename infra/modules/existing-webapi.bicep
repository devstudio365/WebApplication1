// Read-only reference to the existing production API (webapi) App Service.
// It lives in a different resource group than the frontend, and keeps its
// custom domain (api.docably.co.uk) and SSL certificate untouched.
@description('Name of the existing production API App Service.')
param webapiAppName string

resource webapiApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webapiAppName
}

output defaultHostName string = webapiApp.properties.defaultHostName
output webapiAppId string = webapiApp.id
