<# 
.SYNOPSIS 
Set the OSDComputerName task sequence variable for MDT or SCCM task sequences.

.DESCRIPTION
Allows for fully-automatic, semi-automatic or interactive assignment of the OSDComputerName
task sequence variable within an MDT or SCCM task sequence.

.PARAMETER Testing
The is a switch parameter that is used to test the script outside of a SCCM Task Sequence.  
If this -testing is used the script will not load the OSD objects that are only present while a task sequence is running. 
instead it will use write-output to display the selection.  

.PARAMETER DefaultName
Default forced name value (default = "")

.PARAMETER UseLocation
Switch to insert location into new name

.PARAMETER DefaultLocation
Default location code, if -UseLocation is invoked

.PARAMETER LocationFile
Location look-up file, if -UseLocation is invoked

.PARAMETER UseHyphens
Concatenate name components with hyphen delimiter

.PARAMETER SnMaxLen
Maximum length of BIOS serial number, from right-most end, to use
Default is 8

.PARAMETER Interactive
Prompt for name input using GUI form

.EXAMPLE 
powershell -ExecutionPolicy Bypass -File .\Set-ComputerName.ps1 -Testing
 
.EXAMPLE 
powershell -File .\Set-ComputerName.ps1 -Interactive

.EXAMPLE
powershell -File .\Set-ComputerName.ps1 -UseLocation -DefaultLocation "NYC"

.EXAMPLE
powershell -File .\Set-ComputerName.ps1 -UseHyphens

.EXAMPLE
powershell -File .\Set-ComputerName.ps1 -Interactive -DefaultName "DT001"
 
.NOTES 
This is a very simple version of a OSD prompt for a computername. You can add extra validation to the computer name, for example a regular expression test  
to ensure it meets standard form used in your environment. Addtional form object can be added to other options that you may want to set 
task sequence variables for. Also as a simple example, I just added the xaml for the wpf form as a variable in the script. You have the option of storing it in     
a external file if your form gets complex.  

Version 1.0 - 03/08/2018 - David Stein
Version 1.1 - 03/13/2018 - David Stein - Added form size options as param inputs
 
The GUI form aspects are directly adapted from the outstanding work of Jonathan Warnken:
Jonathan Warnken - jon.warnken@gmail.com 
https://gallery.technet.microsoft.com/scriptcenter/Prompt-for-a-computername-6f99fa67
#> 
[CmdletBinding()] 
param ( 
    [parameter(Mandatory=$False, HelpMessage="Interactive testing mode")]
        [switch] $Testing,
    [parameter(Mandatory=$False, HelpMessage="Default name for UI prompt")]
        [string] $DefaultName = "",
    [parameter(Mandatory=$False, HelpMessage="Use location code in name")]
        [switch] $UseLocation,
    [parameter(Mandatory=$False, HelpMessage="Default location code")]
        [string] $DefaultLocation = "",
    [parameter(Mandatory=$False, HelpMessage="Location codes table file")]
        [string] $LocationFile = 'locations.txt',
    [parameter(Mandatory=$False, HelpMessage="Concatenate name using hyphen characters")]
        [switch] $UseHyphens,
    [parameter(Mandatory=$False, HelpMessage="Maximum serial number length")]
        [int] $SnMaxLen = 8,
    [parameter(Mandatory=$False, HelpMessage="Prompt for full device name")]
        [switch] $Interactive,
    [parameter(Mandatory=$False, HelpMessage="Form Height when using Interactive param")]
        [string] $FormHeight = '150',
    [parameter(Mandatory=$False, HelpMessage="Form Width when using Interactive param")]
        [string] $FormWidth = '220',
    [parameter(Mandatory=$False, HelpMessage="Form Caption label when using Interactive param")]
        [string] $FormCaption = 'Computer Name',
    [parameter(Mandatory=$False, HelpMessage="Form Message text when using Inteactive param")]
        [string] $FormMessage = 'New Name',
    [parameter(Mandatory=$False, HelpMessage="Form Textbox width when using Interactive param")]
        [string] $TextBoxSize = '150'
)

function Get-LocationCode {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $GatewayIPAddress,
        [parameter(Mandatory=$False)]
        [string] $DefaultLoc = "",
        [parameter(Mandatory=$False)]
        [string] $DataFile = $LocationFile
    )
    <# format of location data is as follows:
    IPADDRESS=FULLNAME,ABBREV
    10.0.0.1=NEWYORK,NYC
    #>
    if (!(Test-Path -Path $DataFile)) {
        Write-Verbose "data file not found: $DataFile"
        Write-Output ""
        break
    }
    $shortname = ""
    $dataset = Get-Content -Path $DataFile
    if ($dataset.length -gt 0) {
        Write-Verbose "data loaded from text file"
    }
    foreach ($row in $dataset) {
        $rowdata = $row -split '='
        $gateway = $rowdata[0]
        if ($gateway -eq $GatewayIPAddress) {
            $location  = $rowdata[1]
            $fullname  = ($location -split ',')[0]
            $shortname = ($location -split ',')[1]
            Write-Verbose "location: $fullname"
            Write-Verbose "shortname: $shortname"
            break
        }
    }
    if ($shortname -eq "") { $shortname = $DefaultLoc }
    Write-Verbose "location code is: $shortname"
    Write-Output $shortname
}

function Get-ComputerNameInput {
    param (
        [parameter(Mandatory=$False, HelpMessage="Default computer name")] [string] $DefaultDeviceName = "",
        [parameter(Mandatory=$False)] [string] $FormTitle   = 'New Computer Name',
        [parameter(Mandatory=$False)] [string] $FormPrompt  = 'New Name',
        [parameter(Mandatory=$False)] [string] $FormHeight  = '154',
        [parameter(Mandatory=$False)] [string] $FormWidth   = '425',
        [parameter(Mandatory=$False)] [string] $TextBoxSize = '220'
    )
    [xml]$XAML = @' 
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        Title="TITLE" Height="200" Width="500" Topmost="True" WindowStyle="ToolWindow"> 
    <Grid> 
        <Label Name="Computername_label" Content="PROMPT" HorizontalAlignment="Left" Height="27" Margin="0,10,0,0" VerticalAlignment="Top" Width="241"/> 
        <TextBox Name="Computername_text" HorizontalAlignment="Left" Height="27" Margin="146,10,0,0" TextWrapping="Wrap" Text=" " VerticalAlignment="Top" Width="220"/> 
        <Button Name="Continue_button" Content="Continue" HorizontalAlignment="Left" Margin="201,62,0,0" VerticalAlignment="Top" Width="75"/> 
    </Grid> 
</Window> 
'@ 
    $XAML.Window.Height = $FormHeight
    $XAML.Window.Width  = $FormWidth
    $XAML.Window.Title  = $FormTitle
    $XAML.Window.Grid.Label.Content = $FormPrompt
    $XAML.Window.Grid.TextBox.Width = $TextBoxSize
    $XAML.Window.Grid.TextBox.Text  = $DefaultDeviceName
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)  
    $Form = [Windows.Markup.XamlReader]::Load( $reader ) 
    $xaml.SelectNodes("//*[@Name]") | Foreach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)} 
    #$Computername_text.Text = $DefaultDeviceName
    $Continue_button.add_Click({ 
        $Script:NewName = $Computername_text.Text.ToString()
        $Form.Close() 
    })
    $Form.add_KeyDown({
        param (
            [parameter(Mandatory=$True)][Object]$sender,
            [parameter(Mandatory=$True)][Windows.Input.KeyEventArgs]$e
        )
        if ($e.Key -eq 'Enter') { 
            $Script:NewName = $Computername_text.Text.ToString()
            $form.DialogResult = $True 
        }
    })
    $Computername_text.Focus() | Out-Null
    $Form.ShowDialog() | Out-Null
    $result = $Script:NewName
    if ($result -and ($result.length -gt 1)) {
        Write-Output $result.Trim()
    }
    else {
        Write-Output ""
    }
}

function Get-FormFactorCode {
    param ()
    $cff = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty ChassisTypes
    if ($cff.Count -gt 1) { $cff = $cff[0] }
    Write-Verbose "chassis type is $cff"
    # as of Q1-2018, codes are from 1 to 36
    # see https://blogs.technet.microsoft.com/brandonlinton/2017/09/15/updated-win32_systemenclosure-chassis-types/
    switch ($cff) {
         3 { $ff = 'D'; break }
         4 { $ff = 'D'; break }
         5 { $ff = 'D'; break }
         6 { $ff = 'D'; break }
         7 { $ff = 'D'; break }
         8 { $ff = 'L'; break }
         9 { $ff = 'L'; break }
        10 { $ff = 'L'; break }
        11 { $ff = 'L'; break }
        12 { $ff = 'L'; break }
        13 { $ff = 'D'; break }
        14 { $ff = 'L'; break }
        15 { $ff = 'D'; break }
        16 { $ff = 'D'; break }
		17 { $ff = 'D'; break }
		18 { $ff = 'D'; break }
		19 { $ff = 'D'; break }
		20 { $ff = 'D'; break }
		21 { $ff = 'D'; break }
		22 { $ff = 'D'; break }
		23 { $ff = 'D'; break }
		24 { $ff = 'D'; break }
		25 { $ff = 'D'; break }
		26 { $ff = 'D'; break }
		27 { $ff = 'D'; break }
		28 { $ff = 'D'; break }
		29 { $ff = 'D'; break }
		30 { $ff = 'D'; break }
        31 { $ff = 'L'; break }
		32 { $ff = 'L'; break }
		33 { $ff = 'L'; break }
		34 { $ff = 'D'; break }
		35 { $ff = 'D'; break }
		36 { $ff = 'L'; break }
        default { $ff = 'X'; break }
    }
    Write-Verbose "form factor code: $ff"
    Write-Output $ff
}

function Get-SerialNumber {
    param (
        [parameter(Mandatory=$True, HelpMessage="Max length of serial number value")]
        [int] $MaxLen
    )
    $csn = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty SerialNumber
    if ($csn.Count -gt 1) { $csn = $csn[0] }
    Write-Verbose "full serial number is $csn"
    if ($csn.Length -gt $MaxLen) {
        $csn = $csn.Substring($csn.Length - $MaxLen)
    }
    Write-Verbose "truncated serial number is $csn"
    Write-Output $csn
}

if ($Interactive) {
    if (!$Testing) {
        $tsui = New-Object -COMObject Microsoft.SMS.TSProgressUI
        $tsui.CloseProgressDialog() 
    }
    $computername = Get-ComputerNameInput -DefaultDeviceName $DefaultName
}
else {
    $csn = Get-SerialNumber -MaxLen $SnMaxLen
    $cff = Get-FormFactorCode
    if ($UseLocation) {
        $gwa = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $True} | Select-Object -ExpandProperty DefaultIPGateway
        $loc = Get-LocationCode -GatewayIPAddress $gwa -DataFile $LocationFile -DefaultLoc $DefaultLocation
    }
    else {
        $loc = ""
    }
    if ($UseHyphens) {
        if ($loc -ne "") {
            $computername = $loc+'-'+$cff+'-'+$csn
        }
        else {
            $computername = $cff+'-'+$csn
        }
    }
    else {
        if ($loc -ne "") {
            $computername = $loc+$cff+$csn
        }
        else {
            $computername = $cff+$csn
        }
    }
}

if (!($computername -and ($computername.Length -gt 1))) {
    Write-Output "requested name cannot be empty or null"
    break
}
elseif ($computername.Length -gt 15) {
    Write-Output "requested name is longer than maximum of 15 characters"
    break
}
else {
    $badChars = "~/^\*<>|?:"
    $computername.ToCharArray() | Foreach-Object { if($badChars.ToCharArray() -contains $_) {$badname = $True} }
    if ($badname) {
        Write-Output "$computername contains invalid characters"
        break
    }
}
Write-Verbose "computer name is $computername"

if (!$Testing) {
    Write-Verbose "assigning task sequence variables"
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
    $tsenv.Value("OSDComputername") = $computername 
}
else { 
    Write-Output "OSDComputername would be set to $computername"
}
