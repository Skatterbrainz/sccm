<# 
.SYNOPSIS 
Displays a gui prompt for a computername usable in a SCCM OSD Task Sequence.   
 
.PARAMETER testing 
The is a switch parameter that is used to test the script outside of a SCCM Task Sequence.  
If this -testing is used the script will not load the OSD objects that are only present while a task sequence is running. 
instead it will use write-output to display the selection.  
 
.EXAMPLE 
powershell -executionpolicy Bypass -file .\show-OSDPrompt.ps1 
 
.EXAMPLE 
powershell -file .\show-OSDPrompt.ps1 -testing  
 
.NOTES 
This is a very simple version of a OSD prompt for a computername. You can add extra validation to the computer name, for example a regular expression test  
to ensure it meets standard form used in your environment. Addtional form object can be added to other options that you may want to set 
task sequence variables for. Also as a simple example, I just added the xaml for the wpf form as a variable in the script. You have the option of storing it in     
a external file if your form gets complex.  

Version 2.0 1/30/2018 - David Stein
Version 2.1 1/31/2018 - David Stein
Version 2.2 2/01/2018 - David Stein
 
.Author 
Jonathan Warnken - jon.warnken@gmail.com 
https://gallery.technet.microsoft.com/scriptcenter/Prompt-for-a-computername-6f99fa67
#> 
[CmdletBinding()] 
Param( 
    [parameter(Mandatory=$False)]
	    [switch] $SetOUPath,
    [parameter(Mandatory=$False)]
	    [string] $OUBase = 'OU=Peabody Computers,DC=us,DC=root,DC=peabodyenergy,DC=com',
    [parameter(Mandatory=$False)]
	    [switch] $Testing
)

function Get-LocationRegion {
  <#
  .DESCRIPTION
    returns geographic region code from a txt file lookup of a location code
  .EXAMPLE
    Get-LocationRegion -SiteCode "NYC"
    returns "US"
  #>
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $SiteCode,
		[parameter(Mandatory=$False)]
			[string] $DataFile = ".\LocationCodes.txt"
	)
	if (!(Test-Path -Path $DataFile)) {
		# failed to load data file
		Write-Verbose "data file not found: $DataFile"
		Write-Output ""
		break
	}
	$result = ""
	$loclist = Get-Content -Path $DataFile
	foreach ($locset in $loclist) {
		$locx = $locset -split '='
		$loc  = $locx[0]
		$sites = $locx[1] -split ','
		if ($sites.Contains($SiteCode)) {
			$result = $loc
			break
		}
	}
	Write-Verbose "region code is: $result"
	Write-Output $result
}
if(!$Testing){ 
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment #This allows us to read and write the Task Sequence variables 
    $tsui  = New-Object -COMObject Microsoft.SMS.TSProgressUI #This allows us to do stuff to the Progress UI, Like hide it to get it out of the way.  
    $OSDComputername = $tsenv.Value("OSDComputername")
	Write-Verbose "current OSDcomputername is: $OSDComputername"
    $tsui.CloseProgressDialog() 
}

# query machine serial number and chassis type from WMI
$csn = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty SerialNumber
$cff = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty ChassisTypes

# check if return values are an array and if true, then only use the first element
if ($csn.Count -gt 1) { $csn = $csn[0] }
if ($cff.Count -gt 1) { $cff = $cff[0] }

Write-Verbose "serial number is $csn"
Write-Verbose "chassis type is $cff"

# if serial number is longer than 10 chars, get last 10 chars only
if ($csn.Length -gt 10) {
	Write-Verbose "truncating serial number to 10 chars"
    $csn = $csn.Substring($csn.Length - 10)
}
# derive form factor code from chassis type code
switch ($cff) {
     3 { $ff = 'D'; $ousub = 'Desktops'; break }
     4 { $ff = 'D'; $ousub = 'Desktops'; break }
     5 { $ff = 'D'; $ousub = 'Desktops'; break }
     6 { $ff = 'D'; $ousub = 'Desktops'; break }
     7 { $ff = 'D'; $ousub = 'Desktops'; break }
     8 { $ff = 'L'; $ousub = 'Laptops';  break }
     9 { $ff = 'L'; $ousub = 'Laptops';  break }
    10 { $ff = 'L'; $ousub = 'Laptops';  break }
    11 { $ff = 'L'; $ousub = 'Laptops';  break }
    12 { $ff = 'L'; $ousub = 'Laptops';  break }
    13 { $ff = 'D'; $ousub = 'Desktops'; break }
    14 { $ff = 'L'; $ousub = 'Laptops';  break }
    15 { $ff = 'D'; $ousub = 'Desktops'; break }
    16 { $ff = 'D'; $ousub = 'Desktops'; break }
	31 { $ff = 'L'; $ousub = 'Laptops';  break }
    default { $ff = 'X'; $ousub = ''; break }
}

Write-Verbose "form factor code: $ff"
Write-Verbose "ou sub code is: $ousub"

[xml]$XAML = @' 
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        Title="SCCM OSD Computername" Height="154" Width="425" Topmost="True" WindowStyle="ToolWindow"> 
    <Grid> 
        <Label Name="Computername_label" Content="Location:" HorizontalAlignment="Left" Height="27" Margin="0,10,0,0" VerticalAlignment="Top" Width="241"/> 
        <TextBox Name="LocationCode_text" HorizontalAlignment="Left" Height="27" Margin="146,10,0,0" TextWrapping="Wrap" Text=" " VerticalAlignment="Top" Width="220"/> 
        <Button Name="Continue_button" Content="Continue" HorizontalAlignment="Left" Margin="201,62,0,0" VerticalAlignment="Top" Width="75"/> 
    </Grid> 
</Window> 
'@ 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 
#Read XAML 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)  
$Form=[Windows.Markup.XamlReader]::Load( $reader ) 

# add form objects as script variables 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)} 

# set the default value for the form textbox
$LocationCode_text.Text = 'STL'

# assign event handler to the "Continue" button
$Continue_button.add_Click({ 
    $Script:LocationCode = $LocationCode_text.Text.ToString()
    $Form.Close() 
})
# display the form for user input
$Form.ShowDialog() | Out-Null 

# after form is closed, concatenate computer name from input values and other variables
$computername = $Script:LocationCode+$ff+'-'+$csn
Write-Verbose "computer name is $computername"

if ($SetOUPath) {
    # concatenate active directory OU path
    $ouname = Get-LocationRegion -SiteCode $Script:LocationCode
    if ($ouname -ne "") {
        $oupath = "LDAP://OU="+$ouname+",OU="+$ousub+","+$oubase
    }
    else {
        $oupath = "LDAP://OU=New Computers,"+$oubase
    }
}
else {
    $oupath = '[NOT ENABLED]'
}
Write-Verbose "ou path is: $oupath"

if (!$Testing) {
    Write-Verbose "assigning task sequence variables"
    $tsenv.Value("OSDComputername") = $computername 
    if ($SetOUPath) {
        $tsenv.Value("OSDDomainOUName") = $oupath
    }
    Write-Output " OSDComputername set to $($tsenv.value("OSDComputername")) / OU is $oupath " 
}
else { 
    Write-Output " OSDComputername would be set to $computername / OU is $oupath" 
}
