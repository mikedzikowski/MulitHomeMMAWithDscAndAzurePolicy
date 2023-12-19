$connectionString = _ ENTER STORAGE ACCOUNT CONNECTION STRING HERE _
$context = New-AzStorageContext -ConnectionString $connectionString
$getParams = @{
    Context   = $context
    Container = _ STORAGE ACCOUNT CONTAINER NAME _
    Blob      = 'MicrosoftMonitoringAgentMultiHomeSetup.zip'
}
$blob = Get-AzStorageBlob @getParams
$contentUri = $blob.ICloudBlob.Uri.AbsoluteUri