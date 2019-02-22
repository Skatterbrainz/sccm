function Set-CmClientSiteCode {
  <#
  .DESCRIPTION
  .PARAMETER SiteCode
  .EXAMPLE
  Set-CmClientSiteCode
  .EXAMPLE
  Set-CmClientSiteCode -SiteCode "ABC"
  .EXAMPLE
  Invoke-Command -ComputerName "client03" -File "c:\scripts\Set-CmClientSiteCode.ps1"
  #>
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$False)]
		[ValidateLength(0,3)]
		[string] $SiteCode = ""
	)
	try {
		$sms = New-Object –COMObject "Microsoft.SMS.Client"
		$currentSiteCode = $sms.GetAssignedSite()
		Write-Host "current: $currentSiteCode"
		if ($SiteCode -ne "") {
			if ($currentSiteCode –ne $SiteCode) { $sms.SetAssignedSite($SiteCode) }
		}
		else {
			if ($currentSiteCode –ne $sms.AutoDiscoverSite() ) { $sms.SetAssignedSite($sms.AutoDiscoverSite()) }
		}
		$result = $sms.GetAssignedSite()
	}
	catch {
		Write-Error $Error[0].Exception.Message
	}
	finally {
		Write-Output $result
	}
}
