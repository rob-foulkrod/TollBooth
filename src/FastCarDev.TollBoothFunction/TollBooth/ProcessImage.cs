using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using TollBooth.Models;

namespace TollBooth
{
    public class ProcessImage
    {
        private static HttpClient _client;

        [FunctionName("ProcessImage")]
        public async Task Run(
            [BlobTrigger("images/{name}", Source = BlobTriggerSource.EventGrid, Connection = "dataLakeConnection")]byte[] incomingPlate, 
            string name, ILogger log)
        {
            log.LogInformation($"Function triggered");
            string licensePlateText;
            // Reuse the HttpClient across calls as much as possible so as not to exhaust all available sockets on the server on which it runs.
            _client = _client ?? new HttpClient();

            try
            {
                if (incomingPlate != null)
                {
                    log.LogInformation($"Processing {name}");                    

                    licensePlateText = await new FindLicensePlateText(log, _client).GetLicensePlate(incomingPlate);

                    log.LogInformation($"Plate is {licensePlateText}");
                    // Send the details to Event Grid.
                    await new SendToEventGrid(log, _client).SendLicensePlateData(new LicensePlateData()
                    {
                        FileName = name,
                        LicensePlateText = licensePlateText,
                        TimeStamp = DateTime.UtcNow
                    });

                    log.LogInformation($"Finished processing. Detected the following license plate: {licensePlateText}");
                }

                log.LogInformation("No image was provided. Exiting function.");
            }
            catch (Exception ex)
            {
                log.LogError(ex.Message);
                throw;
            }


        }
    }
}
