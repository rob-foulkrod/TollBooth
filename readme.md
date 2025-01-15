# TollBooth MCT Demo Deploy Application

This repository contains the TollBooth Demo Application, designed to demonstrate Azure serverless technologies. The demo showcases how to process vehicle photos, extract license plate data, and store it in a highly available NoSQL data store on Azure CosmosDB.

## Prerequisites

To run this demo, ensure you have the following installed locally:

- Current version of Node.js
- .NET 6 SDK
- powershell version 7 (pwsh)

## Overview

The TollBooth demo scenario includes the following components:

- **Azure App Service**: Simulates car traffic by uploading vehicle images.
- **Azure Storage Account**: Stores the uploaded vehicle images.
- **Azure Cognitive Service**: Performs OCR text recognition on the license plates.
- **Azure CosmosDB**: Stores the extracted license plate data.
- **Azure Functions**: Orchestrates the processing of images and data storage.
- **Event Grid**: Manages event-driven triggers for the Azure Functions.
- **Application Insights**: Provides live metrics and performance monitoring.

## Architecture

The architecture of the TollBooth application is illustrated in the following diagrams:

![Tollbooth Architecture Diagram](./TOLLBOOTH/tollbooth-architecture-overview.png)
![Tollbooth Architecture Flowchart](./TOLLBOOTH/tollbooth-architecture-flowchart.png)

## Deployment


1. **Create a new folder on your machine.**
   ```sh
   mkdir tollbooth
   ```

2. **Navigate to the new folder.**
   ```sh
   cd tollbooth
   ```

3. **Initialize the deployment with `azd init`.**
   ```sh
   azd init -t rob-foulkrod/tollbooth
   ```

4. **Trigger the actual deployment with `azd up`.**
   ```sh
   azd up
   ```


## Usage

After deployment, you can demonstrate the following:

1. **Upload Images**: Use the web application to simulate car traffic by uploading vehicle images.
2. **Process Images**: Azure Functions will process the images and extract license plate data using Azure Cognitive Service.
3. **Store Data**: The extracted data will be stored in Azure CosmosDB.
4. **Monitor Metrics**: Use Application Insights to monitor live metrics and performance of the application.

For detailed step-by-step instructions, refer to the [TollBooth.md](#file:tollbooth.md-context) file.

## Contributing

Contributions to enhance the demo scenario are welcome. Please submit the appropriate issues and pull requests

## License

This project is licensed under the MIT License.
