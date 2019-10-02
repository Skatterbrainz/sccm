<#
#>
[CmdletBinding()]
param (
    [parameter()][ValidateRange(3,15)][int] $MaxSerialLen = 8,
    [parameter()][string] $DefaultOU = 'OU=Devices,OU=CORP,DC=contoso,DC=local',
    [parameter()][string[]] $DepartmentsList = ('ENG','EXE','FIN','ITS'),
    [parameter()][string] $DefaultDeptCode = "ITS",
    [parameter()][string] $desktopOuFile = "desktops-ous.txt",
    [parameter()][string] $laptopOuFile = "laptops-ous.txt"
)
$Script:ScriptVersion = "1910.0200"
$logprefix = 'SETNAME'

function Get-ComputerNameInput {
    [CmdletBinding()]
    param()
    Write-Verbose "*** $LogPrefix : setting up departments list"
    Write-Verbose "*** $LogPrefix : getting bios serial number"
    $fsn = (Get-WmiObject Win32_SystemEnclosure).SerialNumber
    if ([string]::IsNullOrEmpty($fsn) -or $fsn -eq 'None') {
        $Script:WarnFlag = $True
        $sn = ""
    }
    else {
        $sn = $fsn
    }
    Write-Verbose "*** $LogPrefix : full serial number = $fsn"
    if ($sn.Length -gt $MaxSerialLen) {
        Write-Verbose "*** $LogPrefix : truncating serial number to $MaxSerialLen chars"
        $sn = $sn.Substring(0,$MaxSerialLen)
    }
    $mn  = (Get-WmiObject Win32_ComputerSystem).Model
    $nic = @(Get-WmiObject Win32_NetworkAdapterConfiguration | ? {$_.DhcpEnabled -eq $True -and $_.DefaultIPGateway.Length -gt 0})[0]
    $mac = $nic.MacAddress
    $ipa = $nic.IPAddress[0]
    Write-Verbose "*** $LogPrefix : loading xaml form"
    # margin = left,top,right,bottom
    [xml]$XAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="New Computer Installation" Height="300" Width="400" Topmost="True" WindowStyle="ToolWindow"
    WindowStartupLocation="Manual" Top="200" Left="200"
    FocusManager.FocusedElement="{Binding ElementName=ComputerName_text}">
    <Grid>
        <Label Name="Label_Warn" Margin="10,0,0,0" Height="27" Width="300" Content="" HorizontalAlignment="Left" Foreground="#ff0000" VerticalAlignment="Top" />
        <Label Name="Label_Dept" Margin="120,40,0,0" Height="27" Width="60" Content="Dept" Foreground="#C0C0C0" HorizontalAlignment="Left" VerticalAlignment="Top" />
        <Label Name="Label_Num" Margin="205,40,0,0" Height="27" Width="70" Content="SerialNum" Foreground="#C0C0C0" HorizontalAlignment="Left" VerticalAlignment="Top" />
        <ComboBox Name="Combo_Dept" Margin="120,65,0,0" Height="27" Width="60" HorizontalAlignment="Left" VerticalAlignment="Top">
        </ComboBox>
        <TextBox Name="Text_Num" Margin="205,65,0,0" Height="27" Width="80" Text="" HorizontalAlignment="Left" VerticalAlignment="Top" VerticalContentAlignment="Center" MaxLength="8" CharacterCasing="Upper" />
        <Label Name="Label_Model" Margin="30,160,0,0" Height="27" Width="350" Content="Model:" HorizontalAlignment="Left" FontFamily="Courier New" Foreground="#0000ff" VerticalAlignment="Top" />
        <Label Name="Label_Serial" Margin="30,175,0,0" Height="27" Width="350" Content="Serial:" HorizontalAlignment="Left" FontFamily="Courier New" Foreground="#0000ff" VerticalAlignment="Top" />
        <Label Name="Label_Mac" Margin="30,190,0,0" Height="27" Width="350" Content="MAC:" HorizontalAlignment="Left" FontFamily="Courier New" Foreground="#0000ff" VerticalAlignment="Top" />
        <Label Name="Label_IP" Margin="30,205,0,0" Height="27" Width="350" Content="MAC:" HorizontalAlignment="Left" FontFamily="Courier New" Foreground="#0000ff" VerticalAlignment="Top" />
        <Button Name="Continue_button" Margin="140,120,0,0" Height="27" Width="120" Content="Continue" HorizontalAlignment="Left" VerticalAlignment="Top" />
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
    foreach ($dept in ($DepartmentsList -split ',')) {
        $Combo_Dept.AddChild($dept)
    }
    # set default values in form
    if (![string]::IsNullOrEmpty($CompanyLogo)) {
        $Img_Logo.Source = Join-Path -Path $PSScriptRoot -ChildPath $CompanyLogo
    }
    $Window.Title = "New Computer Installation: $ScriptVersion"
    $DeptIndex = $DepartmentsList.IndexOf($DefaultDeptCode)
    $Text_Num.MaxLength = $MaxSerialLen
    $Text_Num.Text = $sn
    $Combo_Dept.SelectedIndex = $DeptIndex

    if ($Script:WarnFlag -eq $True) {
        $Label_Warn.Content = "Warning: Serial Number is not defined on this device!"
    }
    $Label_Model.Content  = "Model....... $mn"
    $Label_Serial.Content = "Serial...... $fsn"
    $Label_Mac.Content    = "MAC......... $mac"
    $Label_IP.Content     = "IP Address.. $ipa"

    # add form handler for pressing Enter on exit
    $Text_Num.add_KeyDown({
        if ($args[1].key -eq 'Return') {
            Write-Verbose "*** $LogPrefix : standard name selected"
            #$Script:Location = $Combo_Loc.SelectedValue
            $Script:DeptCode = $Combo_Dept.SelectedValue
            $Script:IDnumber = $Text_Num.Text.ToString()
            $Form.Close()
        }
    })
    # add form handler for clicking Continue button on exit
    $Continue_button.add_Click({
        Write-Verbose "*** $LogPrefix : standard name selected"
        $Script:DeptCode = $Combo_Dept.SelectedValue
        $Script:IDnumber = $Text_Num.Text.ToString()
        $Form.Close()
    })
    # display the form for the user to interact with
    $Form.ShowDialog() | Out-Null

    # collect input values after form is closed
    Write-Verbose "*** $LogPrefix : Department = $($Script:DeptCode)"
    Write-Verbose "*** $LogPrefix : ID Number = $($Script:IDNumber)"
    # concatenate device name from input values
    if ($Script:DeptCode -ne "" -and $Script:IDNumber -ne "") {
        $result = $Script:DeptCode+'-'+$Script:IDNumber
    }
    else {
        $result = ""
    }
    Write-Output $result
}

function Get-FormFactorCode {
	[CmdletBinding()]
    param ()
    $cff = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty ChassisTypes
	# ignore docks/port replicators which return an array rather than one value
    if ($cff.Count -gt 1) {
        $cff = $cff[0]
        Write-Verbose "*** $LogPrefix : filtering out duplicate for external device"
    }
    Write-Verbose "*** $LogPrefix : chassis type = $cff"
    # as of Q1-2018, codes are from 1 to 36
    # see https://blogs.technet.microsoft.com/brandonlinton/2017/09/15/updated-win32_systemenclosure-chassis-types/
    # desktops
    if ($cff -in (3..7)+(13,34,35)) { $ff = 'D' }
    # laptops
    elseif ($cff -in (10,11,12,14)+(15..30)+(31,32,33,36)) { $ff = 'L' }
    # servers
    elseif ($cff -in (17..24)) { $ff = 'S' }
    # unknown
    else { $ff = 'D' }
    Write-Output $ff
}

function Get-DeviceOU {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)][ValidateLength(3,3)][string] $DeptCode,
        [parameter(Mandatory)][ValidateLength(1,1)][string] $FormFactorCode
    )
    if ($FormFactorCode -eq "D") {
        $ouFile = $desktopOuFile
    }
    else {
        $ouFile = $laptopOuFile
    }
    $oupath = ""
    $ouFilePath = Join-Path -Path $PSScriptRoot -ChildPath $ouFile
    if (!(Test-Path $ouFilePath)) {
        Write-Output "failed to located $ouFilePath"
        break
    }
    try {
        $oulist = Get-Content $ouFilePath
        $oupath = $oulist | %{
            $tmp = $_ -split '~'
            [pscustomobject]@{
                Dept = $tmp[0]
                OU   = $tmp[1]
            }
        } | ? {$_.Dept -eq $DeptCode} | Select-Object -ExpandProperty OU
        if ([string]::IsNullOrEmpty($oupath)) {
            Write-Verbose "*** $LogPrefix : mapping not found, using default OU path"
            $oupath = $DefaultOU
        }
    }
    catch {
        Write-Verbose "*** $LogPrefix : ERROR: $($_.Exception.Message)"
    }
    finally {
        Write-Output $oupath
    }
}

Write-Verbose "*** $LogPrefix : script version: $($Script:ScriptVersion)"

try {
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $tsui  = New-Object -COMObject Microsoft.SMS.TSProgressUI
    $TSActive = $True
    Write-Verbose "*** $LogPrefix : condition -> running in sccm or mdt task sequence environment"
}
catch {
    Write-Verbose "*** $LogPrefix : condition -> not running in a task sequence environment"
}

Write-Verbose "*** $LogPrefix : getting user form input"
if ($TSActive) { $tsui.CloseProgressDialog() }

$newname = Get-ComputerNameInput
$ffcode  = Get-FormFactorCode
if ([string]::IsNullOrEmpty($Script:DeptCode)) {
    $Script:DeptCode = $DefaultDeptCode
}
Write-Verbose "*** $LogPrefix : form factor code = $ffcode"
Write-Verbose "*** $LogPrefix : dept code = $($Script:DeptCode)"
Write-Verbose "*** $LogPrefix : new name = $newname"

$oupath = Get-DeviceOU -DeptCode $Script:DeptCode -FormFactorCode $ffcode
$oupath = "LDAP://$oupath"
Write-Verbose "*** $LogPrefix : ou path = $oupath"

try {
    if ($TSActive) {
        Write-Verbose "*** $LogPrefix : assigning task sequence variables"
        $tsenv.Value("OSDComputerName") = $newname
        $tsenv.Value("OSDDomainOUName") = $oupath
        $tsenv.Value("DEPTCODE") = $Script:DeptCode
        $tsenv.Value("FORMFACTOR") = $ffcode
        Write-Verbose "*** $LogPrefix : computer naming script completed processing"
    }
    else {
        Write-Verbose "*** $LogPrefix : running in interactive mode"
        Write-Verbose "*** $LogPrefix : OSDComputerName = $newname"
        Write-Verbose "*** $LogPrefix : OSDDomainOUName = $oupath"
        Write-Verbose "*** $LogPrefix : DEPTCODE = $($Script:DeptCode)"
        Write-Verbose "*** $LogPrefix : FORMFACTOR = $ffcode"
    }
    Write-Output 0
}
catch {
    Write-Output -1
}