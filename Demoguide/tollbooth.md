[comment]: <> (please keep all comment items at the top of the markdown file)
[comment]: <> (please do not change the ***, as well as <div> placeholders for Note and Tip layout)
[comment]: <> (please keep the ### 1. and 2. titles as is for consistency across all demoguides)
[comment]: <> (section 1 provides a bullet list of resources + clarifying screenshots of the key resources details)
[comment]: <> (section 2 provides summarized step-by-step instructions on what to demo)


[comment]: <> (this is the section for the Note: item; please do not make any changes here)
***
### Tollbooth / Automated Parking Lot / HOV Lanes traffic management - demo scenario

<div style="background: lightgreen; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** Below demo steps should be used **as a guideline** for doing your own demos. Please consider contributing to add additional demo steps.
</div>

[comment]: <> (this is the section for the Tip: item; consider adding a Tip, or remove the section between <div> and </div> if there is no tip)

<div style="background: lightblue; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Tip:** This scenario can be used in both AZ-204 Developing Azure Solutions, as well as in AZ-305 Architecting Azure Solutions. The difference is the level of detail you will go through, which will typically be more in 204, to explain all the configuration options and settings from Functions, Event Grid, where Application Insights could be used with the same level of detail in either classes. In a 204-class, each building block of the architecture could be used in the respective module (e.g. only showing the Azure Functions part when discussing Functions, only zooming in on CosmosDB when discussed,... In a 305-class, you might show the full scenario from triggering traffic using the webapp, to live metrics in Application Insights, and briefly using the architecture diagrams below to explain the topology)
</div>

**Demo scenario story:** Using this demo scenario, you showcase a solution for processing vehicle photos as they are uploaded to a storage account, using serverless technologies on Azure. The license plate data gets extracted using Azure Cognitive Service, and stored in a highly available NoSQL data store on Azure CosmosDB for exporting. The data export process will be orchestrated by a serverless Azure Functions and EventGrid-based component architecture, that coordinates exporting new license plate data to file storage using the Blob Trigger Function. Each aspect of the architecture provides live dashboard views, and more detailed information can be viewed real-time from Azure Application Insights.

At the end of the demo scenario walkthrough, learners will have gained insight on how best to take advantage of the new serverless wave by designing a highly scalable and cost-effective solution that requires very little code and virtually no infrastructure, compared to traditional hosted web applications and services.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/tollbooth-architecture-overview.png" alt="Tollbooth Architecture Diagram" style="width:70%;">
<br></br>

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/tollbooth-architecture-flowchart.png" alt="Tollbooth Architecture Flowchart" style="width:70%;">
<br></br>

***
### 1. What Resources are getting deployed
This scenario deploys the sample **Tollbooth** application architecture, which relies on the following Azure resources all working together: 

* MTTDemoDeployRGc%youralias%TOLLBOOTH - Azure Resource Group.
* %youralias%tbimageuploadapp - Azure App Service Resource, with a web application to 'trigger' car traffic. This is the starting point of the demo scenario
* %youralias%tbdatalake - Azure Storage Account with container /images, holding the actual car license plate photos
* %youralias%tbcomputervision - Azure Cognitive Service, responsible for performing OCR text recognition of car license plates in blob storage 
* %youralias%cosmosdb - Cosmos DB instance, which has database items storing the original image file, license plate text information and time stamp
* %youralias%tbeventgridtopic and blobtopic - Event Grid resources, which trigger different Azure Functions across the scenario
* %youralias%tbappinsights - Application Insights, primarily showing Live Metrics, as well as performance and failures of the full Tollbooth Architecture
* %youralias%tbfunctions and * %youralias%tbevents - Different Azure Functions, handling blob trigger and event trigger scenarios

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/ResourceGroup_Overview.png" alt="Tollbooth Resource Group" style="width:70%;">
<br></br>


### 2. What can I demo from this scenario after deployment

#### Azure App Service - Upload Images

1. The **starting point** of the demo scenario, is the **imageupload** web application. This simulates car traffic for 500 vehicles, which should be enough to see live data dashboard views across all architecture components. Now there is a 1-2 minute delay before the metrics actually show up in the dashboards.

1. Navigate to the imageupload website URL (https://%youralias%tbimageuploadapp.azurewebsites.net/)

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/generate_traffic.png" alt="Generate Car Traffic WebApp" style="width:70%;">
<br></br>

1. Click the **Upload Images** button - this loops to 500

#### Azure Storage Account

1. Once the upload process is complete, navigate to the **%youralias%datalake** Azure Storage Account. 

1. Navigate to the **Images** Container; notice the different image files, generated from the web application. Feel free to select a file and download it, to show it contains a car image with a license plate. You might open different images, to showcase there are different cars (Note: in reality, we used 10 different images, looping 50 times, to generate 500 images in total)

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/datalake-images.png" alt="Storage Account Container with car images" style="width:70%;">
<br></br>

#### Azure Functions

1. Once the images are available in Azure Storage Account, an Azure Function **ProcessImage**, which sends image files to **Azure Cognitive Service** 

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/processimage.png" alt="Azure Function with Blob Trigger" style="width:70%;">
<br></br>

1. Use this Azure Function to explain the concept of triggers (HTTP, Blob Trigger,...) and how the starting point is 'something happens in Blob', which kicks off the Function. 

1. Once the data comes back from **Cognitive Service**, it triggers the next Azure Function **SavePlateData**, which stores text values in Azure CosmosDB.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/saveplatedata.png" alt="SavePlateData Function" style="width:70%;">
<br></br>

#### Event Grid / Topics & Subscriptions

1. Notice that this Function is based on an Event Trigger, coming from Event Grid (%youralias%eventgridtopic). From the Azure Portal, navigate to **Event Grid**, and select **Topics**. Open the EventGridTopic resource**.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/eventgridtopic.png" alt="Event Grid Topic with data" style="width:70%;">
<br></br>

1. Highlight the Event Grid Topic is related to the **Event Grid Subscription** called **SavePlate**, which triggers the actual Azure Function **SavePlateData**. This also clarifies the use case, where Event Grid acts as the orchestrator, watching over certain events to occur, and based on the settings of the subscription, it triggers an Azure Function process.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/eventgridtopic.png" alt="Event Grid Subscription" style="width:70%;">
<br></br>

1. Select the **SavePlate** Event Grid Subscription from the dashboard view. This opens a new dashboard, showing the hierarchy of the event:

- Event Grid Topic : %youralias%eventgridtopic
- Metrics - showing the 500 events
- Azure Function - SavePlateData

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/eventsubscription_hierarchy.png" alt="Event Grid Subscription" style="width:70%;">
<br></br>

1. While talking about Event Grid Subscriptions, there is actually a 2nd subscription in place, which watches over the Azure Blob Storage events. Navigate back to the Azure Storage Account **%youralias%tbdatalake**, and navigate to **Events**. 

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/datalake-events.png" alt="Datalake Events" style="width:70%;">
<br></br>

1. Notice the Event Grid Subscription **blobtopicsubscription**, which is a **Web Hook**, meaning, it gets triggered based on HTTP requests. 

1. From within the Event Subscription detailed dashboard, showing **Metrics** initially, navigate to **Filters**. Highlight the subscription is based on filter **Create Blob**. This is what triggers the Azure Function, based on "a new blob is getting created". All other events in the Storage Account are getting bypassed/neglected.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/eventsubscription_blobcreated.png" alt="Blob Created Event Subscription Filter" style="width:70%;">
<br></br>

#### Cosmos DB

1. Open the %youralias%cosmosdb. Navigate to **Data Explorer**. Show the LicensePlates Database, which has 2 different Containers **NeedsManualReview** (not used in this demo scenario), and **Processed**. The Processed Container is where the actual text information returned from Azure Cognitive Service is getting stored. 

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/cosmosdb_licenseplates.png" alt="CosmosDB database" style="width:70%;">
<br></br>

1. Under Processed, open the **Items** view. This shows the different document items in the container, each document having the license plate, image file name and timestamp in a JSON document format.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/cosmosdb_items.png" alt="CosmosDB database" style="width:70%;">
<br></br>

#### Application Insights

1. Navigate to Application Insights, opening the **%youralias%tbappinsights** resource. Go to **Live Metrics**. This will show a lot of different views about the ongoing processing of Functions, Events, Storage activity and more. 

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/appinsights_livemetrics.png" alt="App Insights - Live Metrics" style="width:70%;">
<br></br>

Note: If you see the "Demo" page, it means you don't have live metrics (anymore), and the processing of the car images is completed already. To generate (new) live data, go back to the imageupload web app, and generate new images by pressing the "Upload images" button.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/appinsights_livemetrics_notavailable.png" alt="App Insights - No Live Metrics Data" style="width:70%;">
<br></br>

1. From within the base charts, scroll down to **Servers** section. There should be anywhere between 2-10 visible. Explain that these "servers" reflect the different Azure Functions instances getting triggered, and handling the image processing from blob to CosmosDB.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/appinsights_servers.png" alt="App Insights - Servers" style="width:70%;">
<br></br>

1. Zoom in on the **sample telemetry** to the right hand side. Explain how the different API-streams of the application topology are visible here. Notice how it shows the Azure Function call "SavePlateData", as well as interaction with "Azure Computer Vision", etc...

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/appinsights_sampletelemetry.png" alt="App Insights - Sample Telemetry" style="width:70%;">
<br></br>

1. Depending when you opened the Live Metrics view, the sample telemetry should have a **red** item **Dependency**, which simulates an issue from the Azure Function to Cognitive Service, showing you the details of the **API POST Action call**.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/appinsights_dependency_error.png" alt="App Insights - Dependency Error" style="width:70%;">
<br></br>

1. Next, select **Application Map** within Application Insights. 

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/appinsights_application_map.png" alt="App Insights - Application Map" style="width:70%;">
<br></br>

1. Explain the usage of Application Map, describing the 2 different views here. The first view **%youralias%events**, shows the number of running (Azure Functions) instances, with different metrics (performance details). The Events are representing communication with Azure CosmosDB. It shows the **number of database calls**, as well as the **average performance** between the Event Functions and CosmosDB. 

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/appinsights_application_map_events.png" alt="App Insights - Events" style="width:70%;">
<br></br>

1. Select the **value** metric in the middle between Events and CosmosDB, to open the more detailed view. This opens a blade to the right-hand side of the Azure Portal, exposing many more details about the processing of events. It shows details about the CosmosDB instance, as well as performance details of each CosmosDB action (GET, Create Document, Get Collection, etc...)

1. Click on **Investigate Performance**

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/appinsights_performance.png" alt="App Insights - Performance Details" style="width:70%;">
<br></br>

1. Use this detailed dashboard to explain the different sections, reflecting chart representations of actual **Log Analytics Queries**. This can be demoed by selecting **View Logs** from the top menu, selecting a section, and opening it in Log Analytics.

<img src="https://github.com/rob-foulkrod/TollBooth/blob/main/Demoguide/TOLLBOOTH/appinsights_performance_loganalytics.png" alt="App Insights - Log Analytics KQL" style="width:70%;">
<br></br>

[comment]: <> (this is the closing section of the demo steps. Please do not change anything here to keep the layout consistant with the other demoguides.)
<br></br>
***
<div style="background: lightgray; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** This is the end of the current demo guide instructions.
</div>




