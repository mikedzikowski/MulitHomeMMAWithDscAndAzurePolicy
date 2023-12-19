Configuration MicrosoftMonitoringAgentMultiHomeSetup
{
    param
    (
        [String]
        [parameter(Mandatory = $true)]
        $MicrosoftMonitoringAgentUri,
        [String]
        [parameter(Mandatory = $false)]
        $MicrosoftMonitoringAgentSetupPath = "C:\Windows\temp\MOMAgent.msi",
        [String]
        [parameter(Mandatory = $true)]
        $PrimaryWorkspaceId,
        [String]
        [parameter(Mandatory = $true)]
        $PrimaryWorkspaceKey,
        [String]
        [parameter(Mandatory = $true)]
        $SecondaryWorkspaceId,
        [String]
        [parameter(Mandatory = $true)]
        $SecondaryWorkspaceKey
    )

    $workspaces = @(
        @{
            "id" = $primaryWorkspaceId
            "key" = $primaryWorkspaceKey
        },
        @{
            "id" = $secondaryWorkspaceId
            "key" = $secondaryWorkspaceKey
        }
    );

    Import-DscResource -ModuleName PSDscResources

    Node localhost {

        Script Installer
        {
            SetScript = {Invoke-WebRequest $using:MicrosoftMonitoringAgentUri -OutFile $using:MicrosoftMonitoringAgentSetupPath}
            TestScript = { Test-Path $using:MicrosoftMonitoringAgentSetupPath }
            GetScript = { @{ Result = (Get-ChildItem -Path $using:MicrosoftMonitoringAgentSetupPath) } }
        }

        MsiPackage MicrosoftMonitoringAgent {
            Ensure = "Present"
            Path  = $MicrosoftMonitoringAgentUri
            ProductId = '{10CA3767-6A8D-4DB9-9798-B7ECB651FD49}'
            Arguments = '/qn NOAPM=1 AcceptEndUserLicenseAgreement=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=1'
            DependsOn = "[Script]Installer"
        }

        Service "HealthService"
        {
            Name = "HealthService"
            State = "Running"
            DependsOn = "[MsiPackage]MicrosoftMonitoringAgent"
        }

        foreach($workspace in $workspaces)
        {
            $workspaceId = $workspace.id;
            $workspaceKey = $workspace.key;

            Script "WS-$workspaceId"
            {
                SetScript =
                {
                    $workspaceId = $Using:workspaceId;
                    $workspaceKey = $Using:workspaceKey;
                    $mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg';
                    $mma.AddCloudWorkspace($workspaceId, $workspaceKey, 1);
                    $mma.ReloadConfiguration();
                }

                TestScript = { Test-Path "HKLM:\SYSTEM\ControlSet001\Services\HealthService\Parameters\Service Connector Services\Log Analytics - $($Using:workspaceId)"}
                GetScript = { @{ Result = (Get-ChildItem "HKLM:\SYSTEM\ControlSet001\Services\HealthService\Parameters\Service Connector Services")} }
                DependsOn = "[MsiPackage]MicrosoftMonitoringAgent"
            }
        }
    }
}

MicrosoftMonitoringAgentMultiHomeSetup
