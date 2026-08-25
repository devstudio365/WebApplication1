// New Application Insights instance for production — shared by both
// production apps (web and devstudio365-webapi), distinguished by cloud role
// name in the collected telemetry. This module only creates monitoring
// resources; it deliberately does NOT touch the production App Services
// themselves, since those stay `existing`-only everywhere else in this
// project. Wiring the connection string into each app is done separately,
// via a targeted CLI command, not through Bicep.
@description('Azure region for the monitoring resources.')
param location string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-webapplication1-production'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-webapplication1-production'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

output connectionString string = appInsights.properties.ConnectionString
