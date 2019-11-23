<#
.SYNOPSIS
    Set OSD TS Variables for renaming computer
.DESCRIPTION
    Set OSD TS Variables for renaming computer, assigning
    AD OU location, and exposing additional TS variables for
    use by subsequent steps (DEPTCODE, FORMFACTOR, SUFFIX)
.PARAMETER MaxSerialLen
    Truncate BIOS serial number. Default = 8 chars
.PARAMETER DefaultOU
    Default OU location when lookup doesn't find an assigned OU
.PARAMETER DepartmentsList
    Array of Department codes to use for name prefix
.PARAMETER DefaultDeptCode
    Default department code from the list of departments in DepartmentsList
.PARAMETER HideSuffix
    Hide Suffix textbox and exclude from naming
.PARAMETER DefaultSuffix
    Default suffix to populate textbox
.PARAMETER FormBackground
    Background color of dialog form. Default = white (#fff)
.PARAMETER LogPrefix
    Text prefix for smsts.log entries to help filter/search. Default = 'SKBZ'
.EXAMPLE
    Set-OSDComputerName6.ps1 -Verbose 
.NOTES
    1910.1400 - DS - Forked from v5. Forked sounds funny. Why not spooned?
    1911.2200 - DS - fixed incorrect ou mapping filenames
#>
[CmdletBinding()]
param (
    [parameter()][ValidateRange(3,15)][int] $MaxSerialLen = 8,
    [parameter()][string] $DefaultOU = 'OU=Devices,OU=CORP,DC=skatterbrainz,DC=local',
    [parameter()][string[]] $DepartmentsList = ('','ACT','ADM','ENG','FIN','HR','ITS'),
    [parameter()][string] $DefaultDeptCode = "ITS",
    [parameter()][string] $HideSuffix,
    [parameter()][string] $DefaultSuffix = "",
    [parameter()][string] $FormBackground = "#fff",
    [parameter()][string] $LogPrefix = 'SKBZ'
)
$Script:ScriptVersion = "1911.2200"

function Get-ComputerNameInput {
    [CmdletBinding()]
    param()
    Write-Verbose "*** $LogPrefix : setting up departments list"
    Write-Verbose "*** $LogPrefix : getting bios serial number"
    $fsn = (Get-CimInstance -ClassName Win32_SystemEnclosure).SerialNumber
    if ([string]::IsNullOrEmpty($fsn) -or $fsn -eq 'None') {
        $Script:WarnFlag = $True
        $sn = ""
    }
    else {
        $sn = $fsn
    }
    if ($sn.Length -gt $MaxSerialLen) {
        Write-Verbose "*** $LogPrefix : truncating serial number to $MaxSerialLen chars"
        $sn = $sn.Substring(0,$MaxSerialLen)
    }
    $mn  = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
    $nic = @(Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object {$_.DhcpEnabled -eq $True -and $_.DefaultIPGateway.Length -gt 0})[0]
    $mac = $nic.MacAddress
    if ($nic.Count -gt 0) {
        $ipa = $nic.IPAddress[0]
        $ipt = "DHCP"
    }
    else {
        $nic = @(Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object {$null -ne $_.IPAddress})
        $mac = $nic.MacAddress
        $ipa = $nic.IPAddress[0]
        $ipt = "STATIC"
    }
    Write-Verbose "*** $LogPrefix : loading xaml form"
    # margin = left,top,right,bottom
    [xml]$XAML = @' 
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    Title="New Computer Name" Height="300" Width="400" Topmost="True" WindowStyle="ToolWindow" 
    WindowStartupLocation="Manual" Top="200" Left="200" 
    FocusManager.FocusedElement="{Binding ElementName=ComputerName_text}"> 
    <Grid> 
        <Label Name="Label_Warn" Margin="10,0,0,0" Height="27" Width="300" Content="" HorizontalAlignment="Left" Foreground="#ff0000" VerticalAlignment="Top" />
        <Label Name="Label_Dept" Margin="85,40,0,0" Height="27" Width="60" Content="Prefix" Foreground="#C0C0C0" HorizontalAlignment="Left" VerticalAlignment="Top" />
        <Label Name="Label_Num" Margin="160,40,0,0" Height="27" Width="70" Content="SerialNum" Foreground="#C0C0C0" HorizontalAlignment="Left" VerticalAlignment="Top" />
        <Label Name="Label_Sfx" Margin="250,40,0,0" Height="27" Width="70" Content="Suffix" Foreground="#C0C0C0" HorizontalAlignment="Left" VerticalAlignment="Top" />
        <ComboBox Name="Combo_Dept" Margin="85,65,0,0" Height="27" Width="60" HorizontalAlignment="Left" VerticalAlignment="Top">
        </ComboBox>
        <TextBox Name="Text_Num" Margin="160,65,0,0" Height="27" Width="80" Text="" HorizontalAlignment="Left" VerticalAlignment="Top" VerticalContentAlignment="Center" MaxLength="8" CharacterCasing="Upper" />
        <TextBox Name="Text_Sfx" Margin="250,65,0,0" Height="27" Width="60" Text="" HorizontalAlignment="Left" VerticalAlignment="Top" VerticalContentAlignment="Center" MaxLength="8" CharacterCasing="Upper" />
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
    $Form.Background = $FormBackground
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
    $Label_IP.Content     = "IP Address.. $ipa ($ipt)"

    if ($HideSuffix) {
        $Text_Sfx.Visibility  = 'Hidden'
        $Label_Sfx.Visibility = 'Hidden'
    }
    else {
        $Text_Sfx.Text = $DefaultSuffix
    }

    # add form handler for pressing Enter on exit
    $Text_Num.add_KeyDown({
        if ($args[1].key -eq 'Return') {
            Write-Verbose "*** $LogPrefix : standard name selected"
            $Script:DeptCode = $Combo_Dept.SelectedValue
            $Script:IDnumber = $Text_Num.Text.ToString()
            $Script:Suffix   = $Text_Sfx.Text.ToString()
            $Form.Close()
        }
    })
    if (!$HideSuffix) {
        $Text_Sfx.add_KeyDown({
            if ($args[1].key -eq 'Return') {
                Write-Verbose "*** $LogPrefix : suffix selected"
                $Script:DeptCode = $Combo_Dept.SelectedValue
                $Script:IDnumber = $Text_Num.Text.ToString()
                $Script:Suffix   = $Text_Sfx.Text.ToString()
                $Form.Close()
            }
        })
    }
    # add form handler for clicking Continue button on exit
    $Continue_button.add_Click({ 
        Write-Verbose "*** $LogPrefix : standard name selected"
        $Script:DeptCode = $Combo_Dept.SelectedValue
        $Script:IDnumber = $Text_Num.Text.ToString()
        $Script:Suffix   = $Text_Sfx.Text.ToString()
        $Form.Close() 
    })
    
    # display the form for the user to interact with
    $Form.ShowDialog() | Out-Null

    # collect input values after form is closed
    Write-Verbose "*** $LogPrefix : Department...: $($Script:DeptCode)"
    Write-Verbose "*** $LogPrefix : ID Number....: $($Script:IDNumber)"
    Write-Verbose "*** $LogPrefix : Suffix.......: $($Script:Suffix)"
    # concatenate device name from input values
    if (![string]::IsNullOrEmpty($Script:IDNumber)) {
        $result = $Script:IDNumber
        if (![string]::IsNullOrEmpty($Script:DeptCode)) {
            $result = $Script:DeptCode+'-'+$result
        }
        if (![string]::IsNullOrEmpty($Script:Suffix)) {
            $result += '-'+"$($Script:Suffix)"
        }
    }
    else {
        $result = ""
    }
    Write-Verbose "*** $LogPrefix : output name...: $result"
    Write-Output $result
}

function Get-FormFactorCode {
    [CmdletBinding()]
    param ()
    try {
        $mn = (Get-CimInstance -Namespace root/cimv2 -Class Win32_ComputerSystem).Model
        $ct = ((Get-CimInstance -Namespace root/cimv2 -Class Win32_SystemEnclosure).ChassisTypes)
        # ignore docks/port replicators which often 
        # return an array rather than one value
        if ($mn -match 'Virtual') { $ff = 'V' }
        else {
            if ($ct.Count -gt 1) { 
                $ct = $ct[0]
                Write-Verbose "*** multiple values returned"
            }
            Write-Verbose "*** wmi chassis type = $ct"
            switch ($ct) {
                {($_ -in (3,4,5,6,7,13,15,24,35))} { $ff = 'D' }
                {($_ -in (8,9,10,12,14,18,21))} { $ff = 'L' }
                {($_ -in (17,19,20,22,23,25,26,27,28,29))} { $ff = 'S' }
                {($_ -in (30,31,32))} { $ff = 'T' }
                {($_ -in (11))} { $ff = 'M' }
                {($_ -in (1,2,33))} { $ff = 'O' }
                {($_ -in (34))} { $ff = 'E' }
            }
        }
        Write-Output $ff
    }
    catch {}
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
if ([string]::IsNullOrEmpty($Script:Suffix)) {
    $Script:Suffix = $DefaultSuffix
}
Write-Verbose "*** $LogPrefix : form factor....... $ffcode"
Write-Verbose "*** $LogPrefix : dept code......... $($Script:DeptCode)"
Write-Verbose "*** $LogPrefix : suffix............ $($Script:Suffix)"
Write-Verbose "*** $LogPrefix : new name.......... $newname"

try {
    if ($TSActive) {
        Write-Verbose "*** $LogPrefix : assigning task sequence variables"
        $tsenv.Value("OSDComputerName") = $newname
        $tsenv.Value("DEPTCODE") = $Script:DeptCode
        $tsenv.Value("FORMFACTOR") = $ffcode
        $tsenv.Value("SUFFIX") = $Script:Suffix
        Write-Verbose "*** $LogPrefix : computer naming script completed processing"
    }
    else {
        Write-Verbose "*** $LogPrefix : *** running in interactive mode ***"
        Write-Verbose "*** $LogPrefix : OSDComputerName = $newname"
        Write-Verbose "*** $LogPrefix : DEPTCODE = $($Script:DeptCode)"
        Write-Verbose "*** $LogPrefix : FORMFACTOR = $ffcode"
        Write-Verbose "*** $LogPrefix : SUFFIX = $($Script:Suffix)"
    }
    Write-Output 0
}
catch {
    Write-Output -1
}