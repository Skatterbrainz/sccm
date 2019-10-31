<#
.NOTES

adapted from: https://blogs.technet.microsoft.com/cmpfekevin/2018/04/05/configmgr-exportimport-hardware-inventory-classes/

#>

function Export-CmHwInventoryClasses {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidatePattern('.*(.xml)')]
        [String] $XMLFile,
        [switch] $Import,
        [parameter(Mandatory=$true)]
        [string] $SiteCode,
        [parameter(Mandatory=$true)]
        [string] $CMProvider = "."
    )

    $CIMProps = @{
        ComputerName = $CMProvider
        Namespace = "root\sms\site_$($SiteCode)"
    }

    $TodaysDate = get-date -Format "yyyy-MM-dd-HHmmss"

    $ExportClientHardwareInventoryClasses = {
        $File = $XMLFile -split '.xml'
        $File = "$($XMLFile)-$($TodaysDate).xml"
        $ExportHWInvClasses = @()    
        $ClientSettings = Get-CimInstance @CIMProps -ClassName SMS_ClientSettings | Get-CimInstance
        $DefaultClientSettings =  Get-CimInstance @CIMProps -ClassName SMS_ClientSettingsDefault | Get-CimInstance
        $DefaultClientSettings | Add-Member -NotePropertyName AgentConfigurations -NotePropertyValue @{}
        $DefaultClientSettings.AgentConfigurations.Add('AgentID',15)
        $DefaultClientSettings.AgentConfigurations.Add('InventoryReportID','{00000000-0000-0000-0000-000000000001}')
        $ClientSettings += $DefaultClientSettings
        Foreach ($ClientSetting in $ClientSettings) {
            if ($HWInvSetting = $ClientSetting.AgentConfigurations | where {$_.AgentID -eq 15}) {
                write-verbose $HWInvSetting.InventoryReportID 
                $HWInvDetails = @{
                    ClientSetting = $ClientSetting
                    AgentConfiguration = $HWInvSetting
                    InventoryReport =  Get-CimInstance @CIMProps -ClassName SMS_InventoryReport -Filter ('InventoryReportID = "' + $HWInvSetting.InventoryReportID + '"') | Get-CimInstance
                }
                $ExportHWInvClasses += $HWInvDetails
            }
        }
        Export-Clixml -InputObject $ExportHWInvClasses -Path $File
    }

    $ImportClientHardwareInventoryClasses = {
        $ImportedHWInvClasses = Import-Clixml $XMLFile
        foreach ($ClientSetting in $ImportedHWInvClasses) {
            $InventoryReport = Get-CimInstance @CIMProps -ClassName SMS_InventoryReport -Filter ('InventoryReportID = "'+ $ClientSetting.InventoryReport.InventoryReportID + '"') | Get-CimInstance
            $InventoryReport.ReportClasses = $ClientSetting.InventoryReport.ReportClasses
            $InventoryReport | Set-CimInstance
        }
    }

    If ($Import) {
        Invoke-Command $ImportClientHardwareInventoryClasses
    } else {
        Invoke-Command $ExportClientHardwareInventoryClasses
    }
}
