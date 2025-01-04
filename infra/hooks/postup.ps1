
if($env:TELEMETRY_ENABLED -eq 'true') {
    Write-Host "Telemetry is enabled. Thank you for supporting the project."
    try {
        $client = [Microsoft.ApplicationInsights.TelemetryClient]::new()
        $client.InstrumentationKey = 'fc040a3a-7a9a-4cab-abd8-57a6bd1e282a'
        $client.Context.Cloud.RoleName = 'rob-foulkrod/TollBooth'
        $client.TrackEvent('DeploymentComplete')
        $client.Flush()
        Write-Host "Telemetry sent successfully."
    } catch {
        Write-Host "Telemetry error: $_"
        Write-Host "This does not affect deployment"
    }
}