using System.Reflection;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using DbUp;

if (args.Length < 2)
{
    throw new InvalidOperationException(
        "Usage: DbMigrator <key-vault-name> <secret-name>. " +
        "Example: DbMigrator kv-webapp1-avwyklhwnltoi StagingDbConnectionString");
}

var vaultName = args[0];
var secretName = args[1];
var vaultUri = new Uri($"https://{vaultName}.vault.azure.net/");

// Reuses the Azure CLI session already authenticated by the azure/login step
// earlier in the pipeline (via OIDC) — no separate credential is passed in,
// and the raw connection string never appears anywhere in the workflow YAML.
var secretClient = new SecretClient(vaultUri, new AzureCliCredential());
var connectionString = (await secretClient.GetSecretAsync(secretName)).Value.Value;

var upgrader = DeployChanges.To
    .SqlDatabase(connectionString)
    .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly())
    .LogToConsole()
    .Build();

var result = upgrader.PerformUpgrade();

if (!result.Successful)
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine(result.Error);
    Console.ResetColor();
    return 1;
}

Console.ForegroundColor = ConsoleColor.Green;
Console.WriteLine("Database is up to date.");
Console.ResetColor();
return 0;
