<#
.SYNOPSIS
Automate Device Name during OSD task sequence

.DESCRIPTION
Automate Device Name during OSD task sequence using flexible runtime inputs
and an optional data file along with optional GUI form for controlled input

.PARAMETER Template
String which contains formatting control using designated keywords with brackets.
[DIRECT] displays a dialog form for explicit name entry (not really automated)
[SERIAL] reads the serial number from WMI
[FORM] reads the form factor from WMI and converts to Laptop or Workstation code
[LOC] reads location code from IP gateway query, or from explicit input
[USERNAME] displays a dialog form for explicit entry

.PARAMETER LocationCode
Force explicit location code. Ignores "osd-locations.csv"

.PARAMETER LaptopCode
Override default code designation for laptops.  Default is "L"

.PARAMETER WorkstationCode
Override default code designation for workstations.  Default is "D"

.PARAMETER DefaultUserName
Force an explicit username.  If blank, and [USERNAME] is specified, the dialog form is used

.PARAMETER ForcedGateway
Force an explicit IPv4 gateway for location mapping. Ignored if [LocationCode] is specified

.PARAMETER ForcedTruncate
Enforce 15-character limit on derived device name.  If derived name is longer than 15 chars
it will be truncated to the left-most 15 chars.  If derived name is longer than 15 chars and
this parameter is not specified, an exception occurs and name is not set!

.PARAMETER NoUpperCase
Use string values as they are queried or entered without forcing them to upper case.

.PARAMETER MaxNameLength
Maximum number of characters allowed for device name from 3 to 15.  Default is 15.

.EXAMPLE
.\Set-OSDComputerName.ps1 -Template "[FORM]-[SERIAL]" -ForcedTruncate -Verbose
Device name will be like "L12345678" or "D12345678"

.EXAMPLE
.\Set-OSDComputerName.ps1 -Template "[LOC]-[FORM]-[USERNAME]" -ForcedTruncate -ForcedGateway '192.168.2.1' -Verbose
Device name will be like "NYC-L-JSMITH"

.EXAMPLE
.\Set-OSDComputerName.ps1 -Template "[FORM]-[LOC][SERIAL]" -ForcedTruncate -Verbose
Device name will be like "L-NYC12345678"

.EXAMPLE
.\Set-OSDComputerName.ps1 -Template "[FORM]-[LOC]-[SERIAL]" -LocationCode "SEA" -ForcedTruncate -Verbose
Device name will be like "L-SEA-12345678"

.EXAMPLE
.\Set-OSDComputerName.ps1 -Template "[USERNAME]" -ForcedTruncate -Verbose
Device name will be like "JSMITH"

.EXAMPLE
.\Set-OSDComputerName.ps1 -Template "[USERNAME]" -DefaultUserName "JSmith" -ForcedTruncate -NoUpperCase -Verbose
Device name will be like "JSmith"

.EXAMPLE
.\Set-OSDComputerName.ps1 -Template "[FORM][SERIAL]" -LaptopCode "N" -WorkstationCode "W" -Verbose
Device name will be like "N12345678" or "W12345678"

.EXAMPLE
.\Set-OSDComputerName.ps1 -Template "[DIRECT]" -ForcedTruncate -MaxNameLength 10 -Verbose
Device name will be whatever is entered in the dialog form, up to 10-chars

.NOTES
Version 0.1 - 20180812 - DS - Initial release
Version 0.2 - 20180913 - DS - Updated for DIRECT+suffix and right-truncate on SERIAL
#>
[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage = "Format Template [SERIAL] [LOC] [FORM] [USERNAME] [DIRECT]")]
        [ValidateNotNullOrEmpty()]
        [string] $Template = "[FORM][SERIAL]",
    [parameter(Mandatory=$False, HelpMessage = "Location Code")]
        [ValidateNotNullOrEmpty()]
        [string] $LocationCode = "",
    [parameter(Mandatory=$False, HelpMessage = "Laptop Form Code")]
        [string] $LaptopCode = 'L',
    [parameter(Mandatory=$False, HelpMessage = "Workstation Form Code")]
        [string] $WorkstationCode = 'D',
    [parameter(Mandatory=$False, HelpMessage = "Default UserName")]
        [string] $DefaultUserName = "",
    [parameter(Mandatory=$False, HelpMessage = "Default Direct Form Value")]
        [string] $DefaultDirect = "",
    [parameter(Mandatory=$False, HelpMessage = "Explicit IP Gateway Address")]
        [string] $ForcedGateway = "",
	[parameter(Mandatory=$False, HelpMessage = "Custom Dialog Caption")]
		[ValidateNotNullOrEmpty()]
		[string] $DialogCaption = "Device Name",
    [parameter(Mandatory=$False, HelpMessage = "Force Truncate Name Lengths if Required")]
        [switch] $ForcedTruncate,
    [parameter(Mandatory=$False, HelpMessage = "Do not force Upper case inputs")]
        [switch] $NoUpperCase,
    [parameter(Mandatory=$False, HelpMessage = "Maximum device name length")]
        [ValidateRange(3,15)]
        [int] $MaxNameLength = 15,
	[parameter(Mandatory=$False, HelpMessage = "Maximum characters allowed in dialog form input")]
		[ValidateRange(1,100)]
		[int] $MaxFormInput = 15
)
$LocationDataFile = ".\osd-locations.csv"
$exitcode = 0

function Get-FormInput {
    param (
        [parameter(Mandatory = $True, HelpMessage="Caption Value")]
        [ValidateNotNullOrEmpty()]
        [string] $Caption,
        [parameter(Mandatory=$False, HelpMessage="Default Input Value")]
        [string] $DefaultValue = ""
    )
    Write-Verbose "getting username from form input..."
    Write-Verbose "action -> building xaml form definition"
    [xml]$xamlForm1 = @' 
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        Title="Device Name" Height="180" Width="300" Topmost="True" WindowStyle="ToolWindow" 
        WindowStartupLocation="Manual" Top="200" Left="200" 
        FocusManager.FocusedElement="{Binding ElementName=Text_UserName}"> 
    <Grid> 
        <Label Name="Label_User" Content="" Margin="10,0,0,0" HorizontalAlignment="Left" Foreground="#ff0000" Height="27" VerticalAlignment="Top" Width="300" />
        <TextBox Name="Text_UserName" Margin="20,40,0,0" Height="27" Width="100" HorizontalAlignment="Left" VerticalAlignment="Top" VerticalContentAlignment="Center" Text="" MaxLength="15" />
        <Button Name="Continue_button" Content="Continue" Margin="130,40,0,0" HorizontalAlignment="Left" VerticalAlignment="Top" Height="27" Width="100"/> 
    </Grid>
</Window> 
'@
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 
        
    # Read XAML string and convert into a form object
    $reader = (New-Object System.Xml.XmlNodeReader $xamlForm1)
    Write-Verbose "displaying user input form..."
    $Form = [Windows.Markup.XamlReader]::Load( $reader ) 

    # Add Form objects as script variables 
    $xamlForm1.SelectNodes("//*[@Name]") | 
        ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)} 
    if (-not([string]::IsNullOrEmpty($UserName))) {
        Write-Verbose "default username = $UserName"
    }
    $Label_User.Content = "Enter $Caption"
    $Text_UserName.Text = $DefaultValue
    $Text_UserName.MaxLength = $MaxNameLength
    $Text_UserName.add_KeyDown({
        if ($args[1].key -eq 'Return') {
            $Script:result = $Text_UserName.Text.ToString()
            $Form.Close()
        }
    })
    # add form handler for clicking Continue button on exit
    $Continue_button.add_Click({ 
        Write-Verbose "action -> user clicked the Continue button"
        $Script:result = $Text_UserName.Text.ToString()
        $Form.Close()
    })
    try {
        $tsui = New-Object -COMObject Microsoft.SMS.TSProgressUI
        Write-Verbose "closing task sequence progress dialog"
        $tsui.CloseProgressDialog()
    }
    catch {
        Write-Verbose "not running within a task sequence environment"
    }
    $Form.ShowDialog() | Out-Null
    Write-Output $Script:result
}

Write-Verbose "input template = $Template"
$tempName = $Template

if ($Template -eq "[DIRECT]") {
    Write-Verbose "template: DIRECT"
    $tempName = Get-FormInput -Caption $DialogCaption -DefaultValue $DefaultDirect
}
else {
    Write-Verbose "parsing template string"
    $tlist = $Template.Split('][') | Where-Object {!([string]::IsNullOrEmpty($_))}
	if ($tlist -contains "DIRECT") {
	    Write-Verbose "template: DIRECT"
		$result = Get-FormInput -Caption $DialogCaption -DefaultValue $DefaultDirect
		$tempName = $tempName.Replace( "[DIRECT]", $result )
	}
    if ($tlist -contains "FORM") {
        Write-Verbose "template: FORM"
        $form = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty 'ChassisTypes'
        Write-Verbose "chassis type = $form"
        switch ($form) {
             8 { $ff = $LaptopCode; break }
             9 { $ff = $LaptopCode; break }
			10 { $ff = $LaptopCode; break }
			14 { $ff = $LaptopCode; break }
			30 { $ff = $LaptopCode; break }
			31 { $ff = $LaptopCode; break }
			32 { $ff = $LaptopCode; break }
			default { $ff = $WorkstationCode; break }
        }
        $tempName = $tempName.Replace( "[FORM]", $ff )
        Write-Verbose "form code = $ff"
    }
    if ($tlist -contains "SERIAL") {
        Write-Verbose "template: SERIAL"
        $sn = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty 'SerialNumber'
        Write-Verbose "serial number = $sn"
        <#
		if ($sn.Length -gt 15) {
            Write-Verbose "truncating to first 15 characters"
            $sn = $sn.Substring( 0, 15 )
            Write-Verbose "serial number = $sn"
        }
		#>
		$testString = $tempName.Replace( "[SERIAL]", $sn )
		Write-Verbose "proposed name is $testString"
		if ($testString.Length -gt $MaxNameLength) {
			# example: length of fullname is 19 chars
			$over = $testString.Length - $MaxNameLength
			Write-Verbose "proposed name is $over chars longer than max of $MaxNameLength"
			# example: over by 4 chars
			# get last 19 - 4 chars of sn
			$newsn = $sn.Substring($over)
			Write-Verbose "tail string is $newsn"
			$tempName = $tempName.Replace( "[SERIAL]", $newsn )
		}
		else {
			$tempName = $tempName.Replace( "[SERIAL]", $sn )
		}
    }
    if ($tlist -contains "LOC") {
        Write-Verbose "template: LOC"
        if (!([string]::IsNullOrEmpty($LocationCode))) {
            Write-Verbose "location code (forced) = $LocationCode"
            $tempName = $tempName.Replace( "[LOC]", $LocationCode )
        }
        else {
            if ([string]::IsNullOrEmpty($ForcedGateway)) {
                Write-Verbose "querying ip gateway to determine location"
                # filter out virtual NIC entries and disabled NICs
                $gateway = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = True' | 
                    Where-Object {$_.DefaultIPGateway -ne $null} | 
                        Select-Object -ExpandProperty DefaultIPGateway
                if ($gateway.Count -gt 1) {
                    Write-Verbose "condition -> multiple active NIC objects found, using the first object only"
                    $gateway = $gateway[0]
                }
                Write-Verbose "ip gateway = $gateway"
            }
            else {
                Write-Verbose "ip gateway (forced) = $ForcedGateway"
                $gateway = $ForcedGateway
            }
            Write-Verbose "importing csv data from locations data file: $LocationDataFile"
            $csvdata = Import-Csv -Path $LocationDataFile
            $LocationCode = $csvdata | 
                Where-Object {$_.IPGateway -eq $gateway} | 
                    Select-Object -ExpandProperty Loc
            Write-Verbose "location code = $LocationCode"
            $tempName = $tempName.Replace( "[LOC]", $LocationCode )
        }
    }
    if ($tlist -contains "USERNAME") {
        Write-Verbose "template: USERNAME"
        if (!([string]::IsNullOrEmpty($DefaultUserName))) {
            Write-Verbose "username (forced) = $DefaultUserName"
            $tempName = $tempName.Replace( "[USERNAME]", $DefaultUserName )
        }
        else {
            $uid = Get-FormInput -DefaultValue $DefaultUserName -Caption 'UserName'
            if (!([string]::IsNullOrEmpty($uid))) {
                $tempName = $tempName.Replace( "[USERNAME]", $uid )
            }
            else {
                Write-Warning "invalid / blank username entered! aborting"
                $tempName = $null
            }
        }
    }
}
Write-Verbose "tentative new name = $tempName"

if ([string]::IsNullOrEmpty($tempName)) {
    $exitcode = -3
}
elseif ($tempName.Length -gt 15) {
    if ($ForcedTruncate) {
        $lx = $tempName.length
        Write-Verbose "$tempName is $lx chars long, exceeds 15 character maximum length!"
        $newname = $tempName.Substring( 0, 15 )
        if (!($NoUpperCase)) { $newname = $newname.ToUpper() }
        Write-Verbose "new name (truncated) = $newname"
    }
    else {
        Write-Warning "$tempName is longer that 15 characters!"
        $exitcode = -1    
    }
}
else {
    $newname = $tempName
    if (!($NoUpperCase)) { $newname = $newname.ToUpper() }
    Write-Verbose "new name = $newname"
}
try {
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $tsenv.value("OSDComputerName") = $newname
    Write-Verbose "updating task sequence variable: OSDComputerName"
}
catch {
    Write-Verbose "not running within a task sequence environment"
}
Write-Output $exitcode
