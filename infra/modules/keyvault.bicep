// Brand-new Key Vault to store real secrets (like database passwords) instead
// of putting them in GitHub or in appsettings.json. Uses RBAC-based access
// (Azure role assignments) rather than the older, harder-to-audit access
// policy model. Who is actually allowed to read secrets gets granted in
// Phase 3, once the pipeline's identity exists.
@description('Azure region for the Key Vault.')
param location string

@description('Key Vault names must be globally unique, 3-24 characters, alphanumeric and hyphens only.')
param vaultName string = 'kv-webapp1-${uniqueString(resourceGroup().id)}'

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: vaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
  }
}

output vaultName string = vault.name
output vaultUri string = vault.properties.vaultUri
