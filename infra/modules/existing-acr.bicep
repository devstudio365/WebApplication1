// Read-only reference to the Azure Container Registry that already exists.
// "existing" means Bicep looks it up but will never create, change, or delete it.
@description('Name of the existing Azure Container Registry.')
param acrName string

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

output loginServer string = acr.properties.loginServer
output acrId string = acr.id
