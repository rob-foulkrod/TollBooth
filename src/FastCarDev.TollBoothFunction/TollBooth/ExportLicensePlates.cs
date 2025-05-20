using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace TollBooth
{
    public class ExportLicensePlates
    {
        [Function("ExportLicensePlates")]
        public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req,
            FunctionContext context)
        {
            var logger = context.GetLogger<ExportLicensePlates>();
            int exportedCount = 0;
            logger.LogInformation("Finding license plate data to export");

            var databaseMethods = new DatabaseMethods(logger);
            var licensePlates = await databaseMethods.GetLicensePlatesToExport();
            if (licensePlates.Any())
            {
                logger.LogInformation($"Retrieved {licensePlates.Count} license plates");
                var fileMethods = new FileMethods(logger);
                var uploaded = await fileMethods.GenerateAndSaveCsv(licensePlates);
                if (uploaded)
                {
                    await databaseMethods.MarkLicensePlatesAsExported(licensePlates);
                    exportedCount = licensePlates.Count;
                    logger.LogInformation("Finished updating the license plates");
                }
                else
                {
                    logger.LogInformation(
                        "Export file could not be uploaded. Skipping database update that marks the documents as exported.");
                }

                logger.LogInformation($"Exported {exportedCount} license plates");
            }
            else
            {
                logger.LogWarning("No license plates to export");
            }

            HttpResponseData response;
            
            if (exportedCount == 0)
            {
                response = req.CreateResponse(HttpStatusCode.NoContent);
            }
            else
            {
                response = req.CreateResponse(HttpStatusCode.OK);
                response.WriteString($"Exported {exportedCount} license plates");
            }

            return response;
        }
    }
}
