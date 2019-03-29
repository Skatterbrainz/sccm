<#
.SYNOPSIS
    Set-OSDDeviceMapping.ps1 - Configure Device Name and OU during SCCM OSD task sequence
    Version 2.6
.DESCRIPTION
    Configure Device Name and OU during SCCM OSD task sequence.
    Requires a boot image with PowerShell components enabled.
    Tested on SCCM 1710 and 1802 using ADK 1709

.PARAMETER ForcedGateway
    Optional forced IP gateway address for testing purposes only.

.PARAMETER DefaultLocation
    Optional forced location code to set as default choice in dialog form

.PARAMETER DefaultDept
    Optional forced department code to set as default choice in dialog form

.EXAMPLE
    Set-OSDDeviceMapping.ps1
    
    no defaults are set, use selects all options

.EXAMPLE
    Set-OSDDeviceMapping.ps1 -DefaultLocation "NYC"
    
    location list is set to "NYC" as the default

.EXAMPLE
    Set-OSDDeviceMapping.ps1 -DefaultLocation "NYC" -DefaultDept "MKT"
    
    location list is set to "NYC" as the default, department list is set to "MKT" as the default

.EXAMPLE
    Set-OSDDeviceMapping.ps1 -ForcedGateway "10.0.0.1" -DefaultLocation "NYC" -DefaultDept "MKT"
    
    location list is set to site which matches 10.0.0.1, and sets department list is set to "MKT" as the default

.NOTES
    1.0 - 05/01/2018 - DS

    USE AT YOUR OWN RISK.  TEST THOROUGHLY IN A SAFE ENVIRONMENT BEFORE ATTEMPTING IN A PRODUCTION ENVIRONMENT.
    User accepts all risk and liability for direct or adapted use of this program code and related files.
    No warranties or guarantees are provided explicit or implied for any purposes.
    
    Requires additional files:
    1. LocMapping.csv
    2. OuMapping.xml
    3. ContosoLogo350x105.png
    
#>
[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="Optional Forced Location Code")]
        [string] $DefaultLocation = "",
    [parameter(Mandatory=$False, HelpMessage="Optional Forced Department Code")]
        [string] $DefaultDept = "",
    [parameter(Mandatory=$False, HelpMessage="Optional forced IP gateway for testing only")]
        [string] $ForcedGateway = "", 
    [parameter(Mandatory=$False, HelpMessage="Optional Default OU LDAP path")]
        [string] $DefaultOU = "",
    [parameter(Mandatory=$False, HelpMessage="Path to Location CSV file")]
        [string] $LocCSVfile = ".\LocMapping.csv",
    [parameter(Mandatory=$False, HelpMessage="Path to ou map XML file")]
        [string] $OuMapXMLfile = ".\oumapping.xml",
    [parameter(Mandatory=$False, HelpMessage="Company Name")]
        [string] $CompanyName = "Contoso",
    [parameter(Mandatory=$False, HelpMessage="Company Logo image file")]
        [string] $CompanyLogo = "ContosoLogo350x105.png"
)
$Script:WarnFlag = $False
$Script:ScriptVersion = "1.0"
<#
1. Get form factor from WMI query (chassis type)
2. Get location from WMI query (gateway)
3. Display dialog for input: DEPT, IDNUM
4. Concatenate device name
5. Get OU path
#>

function Get-ScriptDirectory{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  $Invocation.PSScriptRoot
}
function Get-DeviceName {
    param (
        [parameter(Mandatory=$True)]
        $LocationsList,
        [parameter(Mandatory=$True)]
        $DepartmentsList,
        [parameter(Mandatory=$True)]
        [string] $FormCode,
        [parameter(Mandatory=$False)]
        [string] $DefLoc = "",
        [parameter(Mandatory=$False)]
        [string] $DefDept = ""
    )
    [xml]$XAML = @' 
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        Title="New Computer Installation" Height="370" Width="400" Topmost="True" WindowStyle="ToolWindow" 
        WindowStartupLocation="Manual" Top="200" Left="200" 
        FocusManager.FocusedElement="{Binding ElementName=ComputerName_text}"> 
    <Grid> 
        <Label Name="Label_Warn" Content="" HorizontalAlignment="Left" Foreground="#ff0000" Height="27" Margin="10,0,0,0" VerticalAlignment="Top" Width="300" />
        <Label Name="Label_Desc" Content="Standard Device Name" HorizontalAlignment="Left" Margin="10,30,0,0" Height="27" VerticalAlignment="Top" />
        <Label Name="Label_Loc" Content="Loc" Foreground="#C0C0C0" HorizontalAlignment="Left" Height="27" Margin="10,50,0,0" VerticalAlignment="Top" Width="60" /> 
        <Label Name="Label_Form" Content="Form" Foreground="#C0C0C0" HorizontalAlignment="Left" Height="27" Margin="80,50,0,0" VerticalAlignment="Top" Width="60" />
        <Label Name="Label_Dept" Content="Dept" Foreground="#C0C0C0" HorizontalAlignment="Left" Height="27" Margin="125,50,0,0" VerticalAlignment="Top" Width="60" />
        <Label Name="Label_Num" Content="ID" Foreground="#C0C0C0" HorizontalAlignment="Left" Height="27" Margin="210,50,0,0" VerticalAlignment="Top" Width="60" />
        <ComboBox Name="Combo_Loc" Margin="10,75,0,0" Height="27" Width="60" HorizontalAlignment="Left" VerticalAlignment="Top">
        </ComboBox>
        <Label Name="Label_FormX" Content="" Height="27" Margin="80,75,0,0" HorizontalAlignment="Left" VerticalAlignment="Top" Width="50" />
        <ComboBox Name="Combo_Dept" Margin="125,75,0,0" Height="27" Width="60" HorizontalAlignment="Left" VerticalAlignment="Top">
        </ComboBox>
        <TextBox Name="Text_Num" Margin="210,75,0,0" Height="27" Width="60" HorizontalAlignment="Left" VerticalAlignment="Top" Text="" MaxLength="6" />

        <Label Name="Label_Loc2" Content="Loc" Foreground="#C0C0C0" HorizontalAlignment="Left" Height="27" Margin="10,130,0,0" VerticalAlignment="Top" Width="60" /> 
        <Label Name="Label_Name2" Content="Name" Foreground="#C0C0C0" HorizontalAlignment="Left" Height="27" Margin="80,130,0,0" VerticalAlignment="Top" Width="60" />

        <Label Name="Label_Cust" Content="Remote Device Name" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10,110,0,0" Height="27" Width="300" />
        <ComboBox Name="Combo_Reg" Margin="10,155,0,0" Height="27" Width="60" HorizontalAlignment="Left" VerticalAlignment="Top">
        </ComboBox>
        <TextBox Name="Text_Cust" Margin="80,155,0,0" HorizontalAlignment="Left" VerticalAlignment="Top" Height="27" Width="145" MaxLength="11" CharacterCasing="Upper" />
        <Button Name="Continue_button" Content="Continue" Margin="260,155,0,0" HorizontalAlignment="Left" VerticalAlignment="Top" Height="27" Width="100"/> 
        <Image Name="Img_Logo" Source="" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="25,200,0,0" Width="350" />
    </Grid>
</Window> 
'@
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 
    
    # Read XAML string and convert into a form object
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)  
    $Form=[Windows.Markup.XamlReader]::Load( $reader ) 
    
    # Add Form objects as script variables 
    $xaml.SelectNodes("//*[@Name]") | 
        ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)} 
    
    # populate list box values in form
    foreach ($loc in ($LocationsList -split ',')) {
        $Combo_Loc.AddChild($loc)
    }
    foreach ($dept in ($DepartmentsList -split ',')) {
        $Combo_Dept.AddChild($dept)
    }
    foreach ($idnum in @('000','001','002')) {
        $Combo_Reg.AddChild($idnum)
    }
    # set default values in form
    $Img_Logo.Source = Join-Path -Path $(Get-ScriptDirectory) -ChildPath $CompanyLogo
    $DeptIndex = $DeptList.IndexOf($DefDept)
    $LocIndex  = $LocList.IndexOf($DefLoc)
    Write-Verbose "setting location selection to: $DefLoc"
    $Combo_Loc.SelectedIndex = $LocIndex
    $Combo_Dept.SelectedIndex = $DeptIndex
    $Label_FormX.Content = "`-$FormCode`-"
    if ($Script:WarnFlag -eq $True) {
        $Label_Warn.Content = "Warning: $gateway is not assigned to a location"
    }
    # add form handler for pressing Enter on exit
    $Text_Num.add_KeyDown({
        if ($args[1].key -eq 'Return') {
            if (!([string]::IsNullOrEmpty($Combo_Reg.SelectedValue))) {
                Write-Verbose "user pressed Enter on standard ID textbox"
                Write-Verbose "custom name selected"
                $Script:Location = $Combo_Reg.SelectedValue
                $Script:Custom1  = $Text_Cust.Text.ToString()
                $Script:DeptCode = ""
                $Script:IDnumber = ""
                $Script:CustomName = $True
            }
            else {
                Write-Verbose "standard name selected"
                $Script:Location = $Combo_Loc.SelectedValue
                $Script:Custom1  = ""
                $Script:DeptCode = $Combo_Dept.SelectedValue
                $Script:IDnumber = $Text_Num.Text.ToString()
            }
            $Form.Close()
        }
    })
    $Text_Cust.add_KeyDown({
        if ($args[1].key -eq 'Return') {
            Write-Verbose "user pressed Enter on custom textbox"
            if ($Combo_Reg.SelectedValue -ne "") {
                Write-Verbose "custom name selected"
                $Script:Location = $Combo_Reg.SelectedValue
                $Script:Custom1  = $Text_Cust.Text.ToString()
                $Script:DeptCode = ""
                $Script:IDnumber = ""
                $Script:CustomName = $True
            }
            else {
                Write-Verbose "standard name selected"
                $Script:Location = $Combo_Loc.SelectedValue
                $Script:Custom1  = ""
                $Script:DeptCode = $Combo_Dept.SelectedValue
                $Script:IDnumber = $Text_Num.Text.ToString()
            }
            $Form.Close() 
        }
    })
    # add form handler for clicking Continue button on exit
    $Continue_button.add_Click({ 
        if (!([string]::IsNullOrEmpty($Combo_Reg.SelectedValue))) {
            Write-Verbose "user clicked the Continue button"
            Write-Verbose "custom name selected"
            $Script:Location = $Combo_Reg.SelectedValue
            $Script:Custom1  = $Text_Cust.Text.ToString()
            $Script:DeptCode = ""
            $Script:IDnumber = ""
            $Script:CustomName = $True
        }
        else {
            Write-Verbose "standard name selected"
            $Script:Location = $Combo_Loc.SelectedValue
            $Script:Custom1  = ""
            $Script:DeptCode = $Combo_Dept.SelectedValue
            $Script:IDnumber = $Text_Num.Text.ToString()
        }
        $Form.Close() 
    })
    # display the form for the user to interact with
    $Form.ShowDialog() | Out-Null

    # collect input values after form is closed
    Write-Verbose "Location.....: $($Script:Location)"
    Write-Verbose "Department...: $($Script:DeptCode)"
    Write-Verbose "ID Number....: $($Script:IDNumber)"
    Write-Verbose "Custom.......: $($Script:Custom1)"
    # concatenate device name from input values
    if (!([string]::IsNullOrEmpty($Script:Custom1))) {
        $result = $Script:Location+'-'+$Script:Custom1
    }
    elseif ($Script:Location -ne "" -and $Script:DeptCode -ne "" -and $Script:IDNumber -ne "") {
        $result = $Script:Location+'-'+$FormCode+'-'+$Script:DeptCode+$Script:IDNumber
    }
    else {
        $result = ""
    }
    Write-Verbose "output name...: $result"
    Write-Output $result
}

function Get-LocationPath {
    param (
        [string] $LocationCode,
        $DataSet
    )
    Write-Verbose "getting location path for code: $LocationCode"
    if (('000','001','002').Contains($LocationCode)) {
        $result = 'OU=Regional Managers'
    }
    else {
        $result = $DataSet.locations.location | Where-Object {$_.name -eq $LocationCode} | Select-Object -ExpandProperty path
    }
    Write-Verbose "location path: $result"
    Write-Output $result
}

function Get-DepartmentPath {
    param (
        [string] $DeptCode,
        $DataSet
    )
    $result = $($DataSet | Where-Object {$_.name -eq $DeptCode} | Select-Object -ExpandProperty path)
    Write-Verbose "dept path: $result"
    Write-Output $result
}

function Get-FormFactor {
    $ff = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty ChassisTypes
    switch ($ff) {
         8 { $result = 'Laptops'; break }
         9 { $result = 'Laptops'; break }
        10 { $result = 'Laptops'; break }
        14 { $result = 'Laptops'; break }
        default { $result ='Workstations'; break }
    }
    Write-Output $result
}

# ---------------- do stuff here -----------------

Write-Verbose "script version: $($Script:ScriptVersion)"
try {
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $tsui  = New-Object -COMObject Microsoft.SMS.TSProgressUI
    $TSActive = $True
    Write-Verbose "running in sccm or mdt task sequence environment"
}
catch {
    Write-Verbose "not running in a task sequence environment"
}

if ($ForcedGateway -eq "" ) {
    $gateway = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = True' | 
        Where-Object {$_.DefaultIPGateway -ne $null} | 
            Select-Object -ExpandProperty DefaultIPGateway
}
else {
    $gateway = $ForcedGateway
}
Write-Verbose "gateway address.... $gateway"

if (!(Test-Path $LocCSVfile)) {
    Write-Output "location mapping CSV file not found: $LocCSVfile"
    break
}
if (!(Test-Path $OuMapXMLfile)) {
    Write-Output "ou mapping XML file not found: $OuMapXMLfile"
}
[xml]$xmldata = Get-Content $OuMapXMLfile

$LocList  = $($xmldata.locations.location | Where-Object {$_.name -ne 'ALL'}) | Select-Object -ExpandProperty Name
$AllDepts = $($xmldata.locations.location | Where-Object {$_.name -eq 'ALL'}).departments.department | Select-Object -ExpandProperty Name
$LocData  = Import-Csv -Path $LocCSVfile

if ($DefaultLocation -ne "") {
    $LocCode  = $DefaultLocation
    Write-Verbose "loc code: $LocCode (explicit)"
    $DeptList = $AllDepts
    Write-Verbose "returned $($DeptList.count) departments"
}
else {
    $LocCode  = $LocData | Where-Object {$_.GATEWAY -eq $gateway} | Select-Object -ExpandProperty LOC
    if ([string]::IsNullOrEmpty($LocCode)) {
        $Script:WarnFlag = $True
    }
    Write-Verbose "loc code: $LocCode"
    $DeptList = $AllDepts
    Write-Verbose "returned $($DeptList.count) departments"
}

# set domain root LDAP path
$LdapBase = $xmldata.locations.path
Write-Verbose "ldap base path: $LdapBase"

if ($DefaultDept -ne "") {
    $DeptCode = $DefaultDept
}
else {
    Write-Verbose "default department not specified"
    $DeptCode = ""
}
Write-Verbose "dept code: $DeptCode"
Write-Verbose "dept path: $DeptPath"

$FormType = Get-FormFactor
Write-Verbose "detected form type: $FormType"
$FormCode = $FormType.substring(0,1)

Write-Verbose "getting user form input"
if ($TSActive) { $tsui.CloseProgressDialog() }

$DevName = Get-DeviceName -LocationsList $LocList -DepartmentsList $DeptList -DefLoc $LocCode -FormCode $FormCode -DefDept $DeptCode
Write-Verbose "form closed. collecting user inputs"

if (('000','001','002').Contains($Script:Location)) {
    Write-Verbose "forced override for form factor: Laptops"
    $FormType = "Laptops"
    $FormCode = $FormType.substring(0,1)
    Write-Verbose "override form code: $FormCode"
}
else {
    $FormCode = $FormType.substring(0,1)
    Write-Verbose "form code: $FormCode"
}

$LocSelect  = $Script:Location
$DeptSelect = $Script:DeptCode
Write-Verbose "form select: location..... $LocSelect"
Write-Verbose "form select: department... $DeptSelect"
Write-Verbose "dev name: $DevName"

if ($DevName -ne "") {
    # "OU=Laptops,OU=Marketing,OU=Corp,DC=contoso,DC=local"
    # "OU=Workstations,OU=Sales,DC=contoso,DC=local"

    $LocOU = Get-LocationPath -LocationCode $LocSelect -DataSet $xmldata
    $DeptOU = $($xmldata.locations.location | Where-Object {$_.name -eq $LocSelect}).departments.department | 
                 Where-Object {$_.name -eq $DeptSelect} | Select-Object -ExpandProperty path
    Write-Verbose "location ou: $LocOU"
    Write-Verbose "dept ou: $DeptOU"

    if (!([string]::IsNullOrEmpty($LocOU))) {
        if (!([string]::IsNullOrEmpty($DeptOU))) {
            $DevicePath = 'OU='+$FormType+','+$DeptOU+','+$LocOU
            $oupath = $DevicePath+','+$LdapBase
            $AllGood = $True
        }
        else {
            $DevicePath = 'OU='+$FormType+','+$LocOU
            $oupath = $DevicePath+','+$LdapBase
            $AllGood = $True
        }
    }

    if ($AllGood) {
        if ($TSActive) {
            Write-Verbose "assigning task sequence variables"
            $tsenv.Value("OSDComputerName") = $DevName
            $tsenv.Value("MachineObjectOU") = $OuPath
            $tsenv.Value("DEPTCODE") = $DeptSelect
        }
        else {
            Write-Host "testmode: device name... $DevName"
            Write-Host "testmode: ou path....... $OuPath"
            Write-Host "testmode: deptcode...... $DeptSelect "
        }
        Write-Output 0
    }
    else {
        $msg = "Invalid OU path returned from location query"
        [System.Windows.MessageBox]::Show($msg,'Device Name','Ok','Error')
        Write-Verbose "name or ou path were invalid and not mapped"
        Write-Output -1
    }
}
else {
    $msg = "Invalid Device Name entered"
    [System.Windows.MessageBox]::Show($msg,'Device Name','Ok','Error')
    Write-Verbose "name or ou path were invalid and not mapped"
    Write-Output -1
}
