$connectionString = __YOUR CONNECTION STRING_
$context = New-AzStorageContext -ConnectionString $connectionString
$getParams = @{
    Context   = $context
    Container = __YOUR CONTAINER NAME_
    Blob      = 'MicrosoftMonitoringAgentMultiHomeSetup.zip'
}
$blob = Get-AzStorageBlob @getParams
$contentUri = $blob.ICloudBlob.Uri.AbsoluteUri