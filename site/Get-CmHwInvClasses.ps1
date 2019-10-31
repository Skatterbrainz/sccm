Import-Module dbatools

function Get-CmHwInvClasses {
    [CmdletBinding()]
    param (
      [parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string] $SQLServerName,
      [parameter(Mandatory=$True)]
      [ValidateLength(3,3)]
      [string] $SiteCode
    )
    $output = ""
    try {
        $query = "SELECT DISTINCT irc.ClassName, irc.PropertyName, irc.SMSClassID, 
        CASE WHEN (cip.SettingName IS NOT NULL) THEN cip.SettingName 
        ELSE 'Default Client Settings'
        END AS 'SettingName',
        CASE WHEN cip.CollectionID IS NOT NULL THEN cip.CollectionID 
        ELSE 'SMS00001' END AS 'CollectionID'
        FROM v_InventoryReportClass irc
            LEFT JOIN v_InventoryClassProperty icp ON icp.SMSClassID = irc.SMSClassID
            LEFT JOIN v_CustomInventoryReport cip ON cip.InventoryReportID = irc.InventoryReportID
            ORDER BY SettingName, ClassName, PropertyName"
        $dataset = @(Invoke-DbaQuery -SqlInstance $SQLServerName -Database "CM_$SiteCode" -Query $query -ErrorAction SilentlyContinue)
        $dataset | ForEach-Object {
            $props = [ordered]@{
                SettingName  = $_.SettingName
                ClassName    = $_.ClassName
                PropertyName = $_.PropertyName
                SMSClassID   = $_.SMSClassID
                CollectionID = $_.CollectionID
            }
            New-Object PSObject -Property $props
        }
    }
    catch {
        Write-Error "ERROR: $($Error[0].Exception.Message)"
    }
}
