### This script is used to send an email to the user when the deployment is started.
## the param section is bringing over the parameters from the pipeline, 
## specified in the ScriptArguments section of the task in the pipeline yaml file.
## the param section should be updated based on the deployment values of the scenario, which the MTT needs to know
## such as ACRName, Passwords, IP-address, URL of services, etc....
## these values should also be updated in the last <table> section of the $message variable


param (
    [string]$BuildDefinitionName,
    [string]$To
)

# The $logicappUrl variable is the URL of the logic app that will send the email.
# The $body variable is a hashtable that contains the email details.
# The $subject variable is a hashtable that contains the email subject.
# The $message variable is a hashtable that contains the email message, mainly the HTML layout for the email body.

$logicappUrl = "https://prod-09.centralus.logic.azure.com:443/workflows/1676b43cc2904b74ae085ae494ead6f2/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=OK-Z_dgspUufMWMlBL5316MVf3VMy-KKmQ0Bgb_fXSM"
$body = @{
         To = $To
         Subject = @"
MTTDemoDeploy - $BuildDefinitionName - Deployment Successfully Completed Notification Email
"@
 Message = @"

                
<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=us-ascii"><meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="ProgId" content="Word.Document">
<title></title>
<style>
    /* Prevent WebKit and Windows mobile changing default text sizes */
body, table, td, a {
  -webkit-text-size-adjust: 100%;
  -ms-text-size-adjust: 100%;
}

 /* Remove spacing between tables in Outlook 2007 and up */
table, td {
  mso-table-lspace: 0pt;
  mso-table-rspace: 0pt;
}

/* RESET STYLES */
img {
  border: 0;
  height: auto;
  line-height: 100%;
  outline: none;
  text-decoration: none;
  -ms-interpolation-mode: bicubic;
}

table {
  border-collapse: collapse !important;
  display: inline-table;
}

/* iOS BLUE LINKS */
a[x-apple-data-detectors] {
  color: inherit !important;
  text-decoration: none !important;
  font-size: inherit !important;
  font-family: inherit !important;
  font-weight: inherit !important;
  line-height: inherit !important;
}

/* BASE STYLES */
body {
  height: 100% !important;
  margin: 0 !important;
  padding: 0 !important;
  width: 100% !important;
  background: white;
}

h1, h2, h3, h4, table, td, th, a, p, span, div, i, em, li, ul, .img-block, img, .comment {
  font-family: 'Segoe UI', '-apple-system', 'BlinkMacSystemFont', 'Roboto', 'Arial', sans-serif;
}

td {
  font-size: 14px;
  line-height: 20px;
  color: #212121;
}

a {
  text-decoration: none;
  color: #0078D4;
}

em {
  font-style: normal;
  color: #666;
}

p {
  margin: 0;
}

/* Buttons */
.btn-primary:hover {
  border-color: #007acc !important;
}
.btn-default:hover {
  border-color: #eaeaea !important;
}
.btn-primary:active {
  border-color: #005faa !important;
  background: #005faa !important;
}
.btn-default:active {
  border-color: #F0F0F0 !important;
  background: #F0F0F0 !important;
}

/* Images */
.img-block {
  display: block;
  color: #ccc;
  font-size: 10px;
  max-width: 100%;
}

.img-padding {
  padding: 0 20px 0 0;
}

.comment {
  color: #333333;
  font-size: 14px;
  border-radius: 5px;
}

.comment blockquote {
  color: #666666;
  border-left: 3px solid #a6a6a6;
  padding: 1px 0 1px 15px;
  margin: 12px 0;
}

.comment-gfx {
  padding-top: 20px;
}

.note {
  font-size: 13px;
}

/* INFO TABLE */
.activity-table {
  display: table;
}

.active {
  background: #CEF1DE;font-family: 'Segoe UI', '-apple-system', 'BlinkMacSystemFont', 'Roboto', 'Arial', sans-serif; font-size: 14px; color: #333333; padding: 2px 4px; display: inline-block;
}

.inactive {
  background: #eeeeee;font-family: 'Segoe UI', '-apple-system', 'BlinkMacSystemFont', 'Roboto', 'Arial', sans-serif; font-size: 14px; text-decoration: line-through; color: #666666; padding: 2px 4px; display: inline-block;
}

.row-label {
  font-family: 'Segoe UI', '-apple-system', 'BlinkMacSystemFont', 'Roboto', 'Arial', sans-serif;
  font-size: 14px;
  color: #333;
  padding: 2px 4px;
  line-height: 16px;
  text-align: left;
}

/* List */
.num {
  background: #f2f2f2;
  height: 20px;
  padding: 0 7px;
  font-size: 14px;
}

.code li {
  font-family: Menlo,Monaco,Consolas,"Courier New",monospace !important;
  font-size: 14px;
  text-align: left;
}

span.monospaced {
  font-family: Menlo,Monaco,Consolas,"Courier New",monospace !important;
}

.list li {
  padding: 5px;
}

.data {
  word-break: break-all;
  font-family:monospace;
}

.red {
  color: red;
}

ul, ol {
  padding: 0 20px;
}

ul {
  list-style-type: circle;
}

.anchors {
  list-style-type: square;
}

ul ul, ol ul {
  padding: 0 30px;
}

/* Other */
.author {
  font-size: 13px;
  color: #666;
  font-style: italic;
  padding: 5px 0 0;
}

.code {
  padding:0;
  list-style:none;
  color: #666666;
}

.code li {
  font-family: Menlo,Monaco,Consolas,"Courier New",monospace !important;
}

.container {
  padding: 0px;
}

.content {
  padding: 20px 0px 20px 0px;
}

.title a {
  color: #212121 !important;
  text-decoration: none;
}

.title a:hover {
  text-decoration: underline;
}

/* MOBILE STYLES */
@media screen and (max-width: 525px) {

  .content {
    padding: 0px !important;
  }

  .header {
    padding: 10px 30px !important;
  }
  .mobile-sm-txt {
    font-size: 14px !important;
  }
  .mobile-sm-txt span {
    display: block;
  }

  /* ALLOWS FOR FLUID TABLES */
  .wrapper {
    width: 100% !important;
    max-width: 100% !important;
  }

  /* ADJUSTS LAYOUT OF LOGO IMAGE */
  .logo img {
    margin: 0 auto !important;
  }

  /* HIDE CONTENT ON MOBILE */
  .mobile-hide {
    display: none !important;
  }

  /* GIVE IMAGES MAX WIDTH SO THEY SQUISH NICE */
  .img-max {
    max-width: 100% !important;
    width: 100% !important;
    height: auto !important;
  }

  /* FULL-WIDTH TABLES */
  .responsive-table {
    width: 100% !important;
  }

  /* UTILITY CLASSES FOR ADJUSTING PADDING ON MOBILE */
  .padding {
    padding: 10px 5% 15px 5% !important;
  }
    .img-padding {
    padding: 0;
  }
  .padding-meta {
    padding: 20px !important;
  }
  .no-padding {
    padding: 0 !important;
  }

  /* CONTENT */
  .comment {
    padding: 16px 22px !important;
  }
  .logo {
    margin: 0 auto;
    padding: 10px 0 10px 5% !important;
  }
  .gfx-promo {
    padding-bottom: 20px;
    width: 40% !important;
  }
  .gfx-promo img {
    width: 100%;
  }

  /* ADJUST BUTTONS ON MOBILE */
  .mobile-button-container {
    margin: 0 auto;
    width: 100% !important;
    margin-bottom: 10px !important;
  }
  .mobile-button {
    padding: 4px !important;
    display: block !important;
  }
  .mobile-promos {
    text-align: center !important;
    padding: 30px !important;
  }

  .foot-logo {
    padding: 5px 0 25px !important;
  }
}

/* Extra small device */
@media screen and (max-width: 413px) {
  body[class="body-padding"] {
      padding: 0 !important;
  }
  /* HIDE CONTENT ON MOBILE */
  td[class="mobile-hide-xs"], td[class="mobile-hide-xs comment-gfx"]{
    display:none;
  }
  /* ADJUST BUTTONS ON MOBILE */
  table[class="mobile-button-container"]{
      margin:0 auto;
      width:100% !important;
  }
}

/* Android fix */
div[style*="margin: 16px 0;"] { margin: 0 !important; }


/* MARKDOWN RENDERING STYLES */
.markdown-code {
    background-color: #EAEAEA;
}

.markdown-table {
    border: 1;
    border-collapse: collapse;
    border-style: solid;
    border-width: thin;
    border-color: #A6A6A6;
    padding: 8px 10px 10px 10px;
}

</style>
</head>
<body>



<div class="container" style="font-family: 'Segoe UI', '-apple-system', 'BlinkMacSystemFont', 'Roboto', 'Arial', sans-serif; color: #212121; font-size: 14px; background: #f8f8f8;"><br />
<table style="border-collapse: collapse; width: 100%;" border="0">
<tbody>
<tr>
<td style="width: 100%;">
<table style="border-collapse: collapse; width: 100%; height: 20px;" border="0">
<tbody>
<tr style="height: 20px;">
<td style="width: 65.2993%; height: 20px;"><img src="https://cdn.vsassets.io/content/notifications/v3/microsoft.png" alt="Microsoft" width="80" height="16" /></td>
</tr>
<tr>
<td class="title" style="padding: 0px 0px 24px; color: #212121; font-size: 28px; font-weight: bold; letter-spacing: -0.04em; line-height: 40px; word-break: break-word; height: 80px; width: 65.2993%;">Deployment of $BuildDefinitionName successfully completed</td>
</tr>
<tr>
<td style="text-align: center; height: 280px; width: 65.2993%;"><img style="height: 256px; width: 256px;" src="https://attdemodeploystoacc.blob.core.windows.net/deployartifacts/deploytemplateartifacts/Email/cloud_completed_small.png" alt="Azure_Loading" /></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table style="border-collapse: collapse; width: 100%;" border="0">
<tbody>
<tr>
<td style="width: 33.3333%;">&nbsp;</td>
<td style="padding: 8px 12px; border-radius: 20px; height: 41px;" align="center" bgcolor="#007acc" width="25%"><a class="mobile-button btn-primary" style="font-weight: 500; font-size: 14px; text-decoration: none; padding: 0px; display: inline-block; color: #ffffff;" href="https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups"> Open Azure Portal </a></td>
<td style="width: 33.3333%;">&nbsp;</td>
</tr>
<tr>
<td style="width: 33.3333%;">&nbsp;</td>
<td style="padding: 8px 12px; border-radius: 20px;">&nbsp;</td>
<td style="width: 33.3333%;">&nbsp;</td>
</tr>
</tbody>


</div>
   

"@                        
}

$headers = @{
    'Content-Type' = 'application/json'
}

$splat = @{
    Uri = $logicappUrl
    Method = 'POST'
    Headers = $headers
    Body = $body | ConvertTo-Json
}

Invoke-RestMethod @splat