// Read-only reference to the existing free-tier SQL Managed Instance and its
// production database (TestDB), plus one NEW database (StagingDB) created on
// the SAME instance so staging has isolated data at no extra monthly cost.
@description('Name of the existing free-tier SQL Managed Instance.')
param sqlManagedInstanceName string

@description('Name of the existing production database on the instance.')
param productionDatabaseName string

@description('Name of the new staging database to create on the same instance.')
param stagingDatabaseName string

@description('Region the SQL Managed Instance already lives in (must match exactly — Azure requires this at deploy time and cannot read it off the existing instance).')
param location string

resource sqlMi 'Microsoft.Sql/managedInstances@2021-11-01' existing = {
  name: sqlManagedInstanceName
}

resource productionDb 'Microsoft.Sql/managedInstances/databases@2021-11-01' existing = {
  parent: sqlMi
  name: productionDatabaseName
}

resource stagingDb 'Microsoft.Sql/managedInstances/databases@2021-11-01' = {
  parent: sqlMi
  name: stagingDatabaseName
  location: location
}

output fullyQualifiedDomainName string = sqlMi.properties.fullyQualifiedDomainName
output productionDatabaseId string = productionDb.id
output stagingDatabaseId string = stagingDb.id
