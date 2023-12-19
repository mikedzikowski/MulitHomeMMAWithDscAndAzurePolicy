
$params = @{
    Name          = 'MicrosoftMonitoringAgentMultiHomeSetup'
    Configuration = './MicrosoftMonitoringAgentMultiHomeSetup.mof'
    Type          = 'AuditAndSet'
    Force         = $true
}
New-GuestConfigurationPackage @params