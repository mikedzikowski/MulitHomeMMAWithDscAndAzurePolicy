$PolicyConfig      = @{
    PolicyId      = New-Guid
    ContentUri    = $contentUri
    DisplayName   = 'Microsoft Monitoring Agent audit and set policy'
    Description   = 'Microsoft Monitoring Agent audit and set policy'
    Path          = './DetectMicrosoftMonitoringAgentMultiHomeNotExists.json'
    Platform      = 'Windows'
    PolicyVersion = '1.0.0'
    Mode          = 'ApplyAndAutoCorrect'
  }

  New-GuestConfigurationPolicy @PolicyConfig