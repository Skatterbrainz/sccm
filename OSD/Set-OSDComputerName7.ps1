<#
.SYNOPSIS
	Query AD for next available sequential device name
.DESCRIPTION
	Query AD for next available sequential device name using Form Factor and Location Mapping in the Name
.PARAMETER URI
	URI to web service. This is typically the "http://<SMSProvider>/ConfigMgrWebService/ConfigMgr.asmx"
.PARAMETER SecretKey
	The secret key string set during ConfigMgrWebService installation
.PARAMETER SuffixLength
	Number of characters in numeric suffix portion of name (not the entire name)
.PARAMETER Delimiter
	Option for joining naming components when -Format is Form-Serial: None, Hyphen, Underscore (default: None)
	Hyphen: Form-SerialNumber
	Underscore: Form_SerialNumber
	None: FormSerialNumber
.PARAMETER LocationFile
	Name of location lookup file. Default is "locations.txt" in the module path
.PARAMETER DefaultLocationCode
	Value to use for LOC part of name when gateway IP lookup does not return a match
.EXAMPLE
	Set-OSDComputerName7.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "019230912309" -SuffixLength 5
	Assuming IP gateway matches in locations.txt and returns "NYC", and form factor is "L" (laptop)
	and "NYCL00002" exists in AD, then next name is "NYCL00003"
.EXAMPLE
	Set-OSDComputerName7.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "019230912309" -SuffixLength 5 -Delimiter Hyphen
	Assuming IP gateway matches in locations.txt and returns "NYC", and form factor is "L" (laptop)
	and "NYC-L-00002" exists in AD, then next name is "NYC-L-00003"
.EXAMPLE
	Set-OSDComputerName7.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "019230912309" -SuffixLength 5 -Delimiter Hyphen -DefaultLocationCode "LAX"
	Assuming IP gateway finds no match in locations.txt, and form factor is "L" (laptop)
	and "LAX-L-00002" exists in AD, then next name is "LAX-L-00003"
.NOTES
	Requires the ConfigMgrWebService from SCConfigMgr.com
	20.04.30 - first release without being intoxicated
	20.05.04 - fixed suffixlength parameter bug, still sober
	20.05.06 - fixed verbose in nested functions, and $LocationFile default value
	20.05.07 - added DefaultLocationCode parameter, moved gateway table inside code
#>
[CmdletBinding()]
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $URI,
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SecretKey,
	[parameter()][ValidateSet('None','Hyphen','Underscore')][string] $Delimiter = 'None',
	[parameter()] [string] $LocationFile = ".\locations.txt",
	[parameter()][ValidateRange(2,15)][int] $SuffixLength = 4,
	[parameter()][string] $DefaultLocationCode = ""
)
Write-Verbose "### Set-OSDComputerName7 - version 20.05.07"
#region functions
function Get-NextADDeviceName {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Prefix
	)
	try {
		Write-Verbose "### connecting to web service at $URI"
		$ws = New-WebServiceProxy -Uri $URI -ErrorAction 'stop'
		for ($index = 1; $index -lt 100; $index++) {
			$nextname = $Prefix + $([string]$index).PadLeft($SuffixLength, "0")
			Write-Verbose "### checking name: $nextname"
			$found = ($ws.GetADComputer($SecretKey, $nextname)).SamAccountName
			if (![string]::IsNullOrEmpty($found)) {
				Write-Verbose "### name exists: $nextname"
			}
			else {
				Write-Verbose "### name available: $nextname"
				return $nextname
			}
		}
		Write-Output "no names for this prefix available from 1 to 100"
	}
	catch {
		Write-Error $_.Exception.Message 
	}
}

function Get-FormFactorCode {
	[CmdletBinding()]
	param ()
	$cff = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty ChassisTypes
	# ignore docks/port replicators which return an array rather than one value
	if ($cff.Count -gt 1) { $cff = $cff[0] }
	Write-Verbose "### chassis type is $cff"
	# as of Q1-2018, codes are from 1 to 36
	# see https://blogs.technet.microsoft.com/brandonlinton/2017/09/15/updated-win32_systemenclosure-chassis-types/
	# desktops
	if ($cff -in (3..7)+(13,34,35)) { $ff = 'D' }
	# laptops
	elseif ($cff -in (15..30)+(10,11,12,14,31,32,33,36)) { $ff = 'L' }
	# servers
	elseif ($cff -in (17..24)) { $ff = 'S' }
	# unknown
	else { $ff = 'X' }
	Write-Verbose "### form factor code: $ff"
	Write-Output $ff
}

function Get-LocationCode {
	[CmdletBinding()]
	param (
		[parameter()][string] $DefaultLoc = ""
	)
	try {
		$result = $null
		Write-Verbose "### querying network interface properties"
		$gwa = $(Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | 
			Where-Object {$_.IPEnabled -eq $True -and $_.DefaultIPGateway -ne '::'} | 
				Select-Object -ExpandProperty DefaultIPGateway).Trim()
		Write-Verbose "### ip gateway = $gwa"
		switch ($gwa) {
			'192.168.1.1' { $result = 'NYC' }
			'192.168.2.1' { $result = 'CHI' }
			# add more if needed
			Default { $result = $DefaultLoc }
		}
	}
	catch {
		Write-Error "$($Error[0].Exception.Message -join ',')"
	}
	finally {
		Write-Output $result
	}
}

#endregion

Write-Verbose "### begin set-osdcomputername7"
$loc = Get-LocationCode -Verbose:$VerbosePreference
Write-Verbose "### location code = $loc"
$ffx = Get-FormFactorCode -Verbose:$VerbosePreference
Write-Verbose "### form factor = $ffx"

switch ($Delimiter) {
	'Hyphen' { $pfx = "$($loc)-$($ffx)" }
	'Underscore' { $pfx = "$($loc)`_$($ffx)" }
	Default { $pfx = "$($loc)$($ffx)" }
}
Write-Verbose "### base name = $pfx"

$cn = Get-NextADDeviceName -Prefix $pfx -Verbose:$VerbosePreference
Write-Verbose "### proposed name = $cn"

try {
	$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
	$tsenv.Value("OSDComputerName") = $cn
	Write-Verbose "### assigned OSDComputerName = $cn"
}
catch {
	Write-Verbose "### not running in a task sequence"
	Write-Verbose "### would have assigned OSDComputerName to $cn"
}
finally {
	Write-Output $cn
}