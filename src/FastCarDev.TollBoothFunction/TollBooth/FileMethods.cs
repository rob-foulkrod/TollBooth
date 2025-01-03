using System.Globalization;
using CsvHelper;
using CsvHelper.Configuration;
using Microsoft.Extensions.Logging;
using Azure.Storage.Blobs;
using TollBooth.Models;

namespace TollBooth
{
  internal class FileMethods
  {
    private BlobClient _blobClient;
    private readonly BlobContainerClient _containerClient;
    private readonly string _containerName = Environment.GetEnvironmentVariable("exportCsvContainerName");
    private readonly string _blobStorageConnection = Environment.GetEnvironmentVariable("blobStorageConnection");
    private readonly ILogger _log;

    public FileMethods(ILogger log)
    {
      _log = log;
      // Retrieve storage account information from connection string.
      _containerClient = new BlobContainerClient(_blobStorageConnection, _containerName);
      _containerClient.CreateIfNotExists();
    }

    public async Task<bool> GenerateAndSaveCsv(IEnumerable<LicensePlateDataDocument> licensePlates)
    {
      var successful = false;

      _log.LogInformation("Generating CSV file");
      string blobName = $"{DateTime.UtcNow:s}.csv";

      var config = new CsvConfiguration(CultureInfo.InvariantCulture)
      {
        Delimiter = ","
      };

      using (var stream = new MemoryStream())
      {
        using (var textWriter = new StreamWriter(stream))
        using (var csv = new CsvWriter(textWriter, config))
        {
          csv.WriteRecords(licensePlates.Select(ToLicensePlateData));
          await textWriter.FlushAsync();

          _log.LogInformation($"Beginning file upload: {blobName}");
          try
          {
            // Retrieve reference to a blob.
            _blobClient = _containerClient.GetBlobClient(blobName);

            // Upload blob.
            stream.Position = 0;
            // TODO 7: Asyncronously upload the blob from the memory stream.
            // COMPLETE: await blob...;

            await _blobClient.UploadAsync(stream);

            successful = true;
          }
          catch (Exception e)
          {
            _log.LogCritical($"Could not upload CSV file: {e.Message}", e);
            successful = false;
          }
        }
      }

      return successful;
    }

    /// <summary>
    /// Used for mapping from a LicensePlateDataDocument object to a LicensePlateData object.
    /// </summary>
    /// <param name="source"></param>
    /// <returns></returns>
    private static LicensePlateData ToLicensePlateData(LicensePlateDataDocument source)
    {
      return new LicensePlateData
      {
        FileName = source.fileName,
        LicensePlateText = source.licensePlateText,
        TimeStamp = source.Timestamp
      };
    }
  }
}
