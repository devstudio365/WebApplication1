// DISASTER RECOVERY ONLY — this file is never part of the normal deployment
// (main.bicep). It exists purely as tested, verified insurance: if the real
// ACR were ever actually lost, this is how you'd recreate it from nothing.
// Validate with `az bicep build` / `what-if` only — never run for real while
// the production registry is alive.
@description('Name of the Container Registry.')
param acrName string = 'devstudio35'

@description('Region — must match where the real ACR lives, since region cannot be changed after creation.')
param location string = 'northeurope'

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
  }
}

output loginServer string = acr.properties.loginServer
output acrId string = acr.id
