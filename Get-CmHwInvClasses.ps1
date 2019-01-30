Import-Module dbatools

function Get-CmHwInvClasses {
    param (
      [parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string] $SQLServerName,
      [parameter(Mandatory=$True)]
      [ValidateLength(3,3)]
      [string] $SiteCode
    )
    try {
      $query = 'SELECT [Namespace],ClassName,SMSClassID,SMSGroupName,Properties 
      FROM v_InventoryClass ORDER BY NameSpace, ClassName, SMSClassID'
      $dataset = Invoke-DbaQuery -SqlInstance $SQLServerName -Database "CM_$SiteCode" -Query $query -ErrorAction Stop
      $dataset | Foreach-Object {
          $ns = $_.Namespace
          $cn = $_.ClassName
          $gn = $_.SMSGroupName
          [xml]$p  = $_.Properties
          $plist = @($p.Properties.Property | Foreach-Object {$_.PropertyName})
          $px = [ordered]@{
              Namespace = $ns
              ClassName = $cn
              GroupName = $gn
              Properties = $px
          }
          New-Object PSObject -Property $px
      }
    }
    catch {
      Write-Error "Error: $($Error[0].Exception.Message)"
    }
}

$classdata = Get-CmHwInvClasses
$classdata | Format-List
