// ============================================================================
// DISASTER RECOVERY BICEP — NOT part of the normal deployment.
//
// This is deliberately separate from ../main.bicep and is never wired into
// it. Its only purpose is tested, verified insurance: proof that the
// production ACR and both production App Services *could* be rebuilt from
// nothing if they were ever genuinely lost.
//
// Validate with `az bicep build` and `az deployment sub what-if` only.
// Never run this for real (`az deployment sub create`) while the real
// production resources are alive — only if they are genuinely gone.
//
// Deliberately NOT covered here, by design:
//   - The SQL Managed Instance (networking-heavy, slow to provision, and a
//     free promotional offer that may not be repeatable — recreate this
//     one yourself via the Azure Portal if it's ever needed).
//   - Custom domains and SSL certificates (docably.co.uk, api.docably.co.uk)
//     — provision these yourself via the Azure Portal after running this,
//     since certificate issuance depends on DNS validation this file can't
//     control.
// ============================================================================
targetScope = 'subscription'

@description('Region for the ACR and the App Service Plan / web app.')
param acrLocation string = 'northeurope'

@description('Region for the App Services (both currently live in Poland Central).')
param appLocation string = 'polandcentral'

param productionResourceGroupName string = 'DefaultResourceGroup-NEU'
param webapiResourceGroupName string = 'devstudio365-webapi_group'

module acr 'acr.bicep' = {
  name: 'dr-acr'
  scope: resourceGroup(productionResourceGroupName)
  params: {
    location: acrLocation
  }
}

module web 'production-web.bicep' = {
  name: 'dr-production-web'
  scope: resourceGroup(productionResourceGroupName)
  params: {
    location: appLocation
    acrLoginServer: acr.outputs.loginServer
  }
}

module webapi 'production-webapi.bicep' = {
  name: 'dr-production-webapi'
  scope: resourceGroup(webapiResourceGroupName)
  params: {
    location: appLocation
    acrLoginServer: acr.outputs.loginServer
    planId: web.outputs.planId
  }
}

module acrAccess 'acr-access.bicep' = {
  name: 'dr-acr-access'
  scope: resourceGroup(productionResourceGroupName)
  params: {
    principalIds: [
      web.outputs.webAppPrincipalId
      webapi.outputs.identityPrincipalId
    ]
  }
}

output acrLoginServer string = acr.outputs.loginServer
output webDefaultHostName string = web.outputs.defaultHostName
output webapiDefaultHostName string = webapi.outputs.defaultHostName
