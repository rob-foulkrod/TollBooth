using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using TollBooth.Models;

namespace TollBooth
{
    public class ProcessImage
    {
        private readonly IHttpClientFactory _httpClientFactory;

        public ProcessImage(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        [Function("ProcessImage")]
        public async Task Run(
            [BlobTrigger("images/{name}", Connection = "dataLakeConnection")] byte[] incomingPlate,
            string name, FunctionContext context)
        {
            var logger = context.GetLogger<ProcessImage>();
            logger.LogInformation($"Function triggered");
            string licensePlateText;
            // Get HttpClient from factory
            var client = _httpClientFactory.CreateClient();

            try
            {
                if (incomingPlate != null)
                {
                    logger.LogInformation($"Processing {name}");

                    licensePlateText = await new FindLicensePlateText(logger, client).GetLicensePlate(incomingPlate);

                    logger.LogInformation($"Plate is {licensePlateText}");
                    // Send the details to Event Grid.
                    await new SendToEventGrid(logger, client).SendLicensePlateData(new LicensePlateData()
                    {
                        FileName = name,
                        LicensePlateText = licensePlateText,
                        TimeStamp = DateTime.UtcNow
                    });

                    logger.LogInformation($"Finished processing. Detected the following license plate: {licensePlateText}");
                }

                logger.LogInformation("No image was provided. Exiting function.");
            }
            catch (Exception ex)
            {
                logger.LogError(ex.Message);
                throw;
            }
        }
    }
}
