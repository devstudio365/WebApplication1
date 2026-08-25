using System.Reflection;
using DbUp;

var connectionString = args.FirstOrDefault()
    ?? Environment.GetEnvironmentVariable("DB_MIGRATOR_CONNECTION_STRING")
    ?? throw new InvalidOperationException(
        "No connection string supplied. Pass it as the first command-line argument, " +
        "or set the DB_MIGRATOR_CONNECTION_STRING environment variable.");

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
