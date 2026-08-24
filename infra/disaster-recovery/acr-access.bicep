// DISASTER RECOVERY ONLY — see acr.bicep for the full explanation.
// Grants AcrPull to both production apps' identities.
@description('Name of the ACR.')
param acrName string = 'devstudio35'

@description('Managed identity principal IDs to grant AcrPull on the registry.')
param principalIds array

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d' // built-in "AcrPull" role, pull-only

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalId in principalIds: {
  name: guid(acr.id, principalId, acrPullRoleId)
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}]
