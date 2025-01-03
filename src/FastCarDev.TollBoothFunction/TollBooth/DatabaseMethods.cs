using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Linq;
using Microsoft.Extensions.Logging;
using TollBooth.Models;

namespace TollBooth
{
  internal class DatabaseMethods
  {
    private readonly string _endpointUrl = Environment.GetEnvironmentVariable("cosmosDBEndPointUrl");
    private readonly string _authorizationKey = Environment.GetEnvironmentVariable("cosmosDBAuthorizationKey");
    private readonly string _databaseId = Environment.GetEnvironmentVariable("cosmosDBDatabaseId");
    private readonly string _collectionId = Environment.GetEnvironmentVariable("cosmosDBCollectionId");
    private readonly ILogger _log;
    // Reusable instance of DocumentClient which represents the connection to a Cosmos DB endpoint.
    private CosmosClient _client;

    public DatabaseMethods(ILogger log)
    {
      _log = log;
    }

    /// <summary>
    /// Retrieves all license plate records (documents) that have not yet been exported.
    /// </summary>
    /// <returns></returns>
    public async Task<List<LicensePlateDataDocument>> GetLicensePlatesToExport()
    {
      _log.LogInformation("Retrieving license plates to export");
      int exportedCount = 0;
      List<LicensePlateDataDocument> licensePlates;

      using (_client = new CosmosClient(_endpointUrl, _authorizationKey))
      {
        Database database = await _client.CreateDatabaseIfNotExistsAsync(id: _databaseId);
        Container container = database.GetContainer(id: _collectionId);
        var queryable = container.GetItemLinqQueryable<LicensePlateDataDocument>(true);
        licensePlates = queryable
          .Where(l => l.exported == false)
          .ToList();
      }

      exportedCount = licensePlates.Count();
      _log.LogInformation($"{exportedCount} license plates found that are ready for export");
      return licensePlates;
    }

    /// <summary>
    /// Updates license plate records (documents) as exported. Call after successfully
    /// exporting the passed in license plates.
    /// In a production environment, it would be best to create a stored procedure that
    /// bulk updates the set of documents, vastly reducing the number of transactions.
    /// </summary>
    /// <param name="licensePlates"></param>
    /// <returns></returns>
    public async Task MarkLicensePlatesAsExported(IEnumerable<LicensePlateDataDocument> licensePlates)
    {
      _log.LogInformation("Updating license plate documents exported values to true");

      using (_client = new CosmosClient(_endpointUrl, _authorizationKey))
      {
        Database database = await _client.CreateDatabaseIfNotExistsAsync(id: _databaseId);
        Container container = database.GetContainer(id: _collectionId);

        foreach (var licensePlate in licensePlates)
        {
          licensePlate.exported = true;
          var response = await container.ReplaceItemAsync(id: licensePlate.Id, item: licensePlate);
          
          var updated = response.Resource;
          _log.LogInformation($"Exported value of updated document: {updated.exported}");
        }
      }
    }

  }
}
