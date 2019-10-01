[CmdletBinding()]
param (
    [parameter()][ValidateRange(3,15)][int] $MaxSerialLen = 8,
    [parameter()][string] $DefaultOU = 'OU=Devices,OU=CORP,DC=contoso,DC=local',
    [parameter()][string[]] $DepartmentsList = ('ENG','EXE','FIN','HRS','ITS','MKT'),
    [parameter()][string] $DefaultDeptCode = "ITS"
)
$Script:ScriptVersion = "1909.2605"

function Get-ComputerNameInput {
    [CmdletBinding()]
    param()
    Write-Verbose "*** setting up departments list"
    Write-Verbose "*** getting bios serial number"
    $sn = (Get-WmiObject Win32_SystemEnclosure).SerialNumber
    if ([string]::IsNullOrEmpty($sn) -or $sn -eq 'None') {
        $Script:WarnFlag = $True
        $sn = ""
    }
    if ($sn.Length -gt $MaxSerialLen) {
        Write-Verbose "*** truncating serial number to $MaxSerialLen chars"
        $sn = $sn.Substring(0,$MaxSerialLen)
    }
    Write-Verbose "*** loading xaml form"
    [xml]$XAML = @' 
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    Title="New Computer Installation" Height="300" Width="400" Topmost="True" WindowStyle="ToolWindow" 
    WindowStartupLocation="Manual" Top="200" Left="200" 
    FocusManager.FocusedElement="{Binding ElementName=ComputerName_text}"> 
    <Grid> 
        <Label Name="Label_Warn" Content="" HorizontalAlignment="Left" Foreground="#ff0000" Height="27" Margin="10,0,0,0" VerticalAlignment="Top" Width="300" />
        <Label Name="Label_Dept" Content="Dept" Foreground="#C0C0C0" HorizontalAlignment="Left" Height="27" Margin="125,50,0,0" VerticalAlignment="Top" Width="60" />
        <Label Name="Label_Num" Content="SerialNum" Foreground="#C0C0C0" HorizontalAlignment="Left" Height="27" Margin="210,50,0,0" VerticalAlignment="Top" Width="70" />
        <ComboBox Name="Combo_Dept" Margin="125,75,0,0" Height="27" Width="60" HorizontalAlignment="Left" VerticalAlignment="Top">
        </ComboBox>
        <TextBox Name="Text_Num" Margin="210,75,0,0" Height="27" Width="80" HorizontalAlignment="Left" VerticalAlignment="Top" VerticalContentAlignment="Center" Text="" MaxLength="8" CharacterCasing="Upper" />
        <Button Name="Continue_button" Content="Continue" Margin="134,120,0,0" HorizontalAlignment="Left" VerticalAlignment="Top" Height="27" Width="120"/> 
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
    $DeptIndex = $DepartmentsList.IndexOf($DefaultDeptCode)
    #$LocIndex  = $LocList.IndexOf($DefLoc)
    $Text_Num.MaxLength = $MaxSerialLen
    $Text_Num.Text = $sn
    $Combo_Dept.SelectedIndex = $DeptIndex

    if ($Script:WarnFlag -eq $True) {
        $Label_Warn.Content = "Warning: Serial Number is not defined on this device!"
    }

    # add form handler for pressing Enter on exit
    $Text_Num.add_KeyDown({
        if ($args[1].key -eq 'Return') {
            Write-Verbose "*** standard name selected"
            $Script:DeptCode = $Combo_Dept.SelectedValue
            $Script:IDnumber = $Text_Num.Text.ToString()
            $Form.Close()
        }
    })
    # add form handler for clicking Continue button on exit
    $Continue_button.add_Click({ 
        Write-Verbose "*** standard name selected"
        $Script:DeptCode = $Combo_Dept.SelectedValue
        $Script:IDnumber = $Text_Num.Text.ToString()
        $Form.Close() 
    })
    # display the form for the user to interact with
    $Form.ShowDialog() | Out-Null

    # collect input values after form is closed
    Write-Verbose "*** Department...: $($Script:DeptCode)"
    Write-Verbose "*** ID Number....: $($Script:IDNumber)"
    # concatenate device name from input values
    if ($Script:DeptCode -ne "" -and $Script:IDNumber -ne "") {
        $result = $Script:DeptCode+'-'+$Script:IDNumber
    }
    else {
        $result = ""
    }
    Write-Verbose "*** output name...: $result"
    Write-Output $result
}

function Get-FormFactorCode {
	[CmdletBinding()]
    param ()
    $cff = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty ChassisTypes
	# ignore docks/port replicators which return an array rather than one value
    if ($cff.Count -gt 1) { $cff = $cff[0] }
    Write-Verbose "*** chassis type is $cff"
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
    Write-Verbose "*** form factor code: $ff"
    Write-Output $ff
}

function Get-DeviceOU {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)][ValidateLength(3,3)][string] $DeptCode,
        [parameter(Mandatory)][ValidateLength(1,1)][string] $FormFactorCode
    )
    if ($FormFactorCode -eq "D") {
        $ouFile = "desktops-ous.txt"
    }
    else {
        $ouFile = "laptops-ous.txt"
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
        } | ? {$_.Dept -eq $DeptCode} | Select -ExpandProperty OU
        if ([string]::IsNullOrEmpty($oupath)) {
            Write-Verbose "*** mapping not found, using default OU path"
            $oupath = $DefaultOU
        }
    }
    catch {
        Write-Verbose "ERROR: $($_.Exception.Message)"
    }
    finally {
        Write-Output $oupath
    }
}

Write-Verbose "*** script version: $($Script:ScriptVersion)"

try {
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $tsui  = New-Object -COMObject Microsoft.SMS.TSProgressUI
    $TSActive = $True
    Write-Verbose "*** condition -> running in sccm or mdt task sequence environment"
}
catch {
    Write-Verbose "*** condition -> not running in a task sequence environment"
}

Write-Verbose "*** getting user form input"
if ($TSActive) { $tsui.CloseProgressDialog() }

$newname = Get-ComputerNameInput
$ffcode  = Get-FormFactorCode
if ([string]::IsNullOrEmpty($Script:DeptCode)) {
    $Script:DeptCode = $DefaultDeptCode
}
Write-Verbose "*** form factor code = $ffcode"
Write-Verbose "*** dept code = $($Script:DeptCode)"
Write-Verbose "*** new name = $newname"

$oupath = Get-DeviceOU -DeptCode $Script:DeptCode -FormFactorCode $ffcode
$oupath = "LDAP://$oupath"
Write-Verbose "*** ou path = $oupath"

try {
    if ($TSActive) {
        Write-Verbose "*** assigning task sequence variables"
        $tsenv.Value("OSDComputerName") = $newname
        $tsenv.Value("OSDDomainOUName") = $oupath
        $tsenv.Value("DEPTCODE")   = $Script:DeptCode
        $tsenv.Value("FORMFACTOR") = $ffcode
        Write-Verbose "*** computer naming script completed processing"
    }
    else {
        Write-Verbose "*** running in interactive mode"
        Write-Verbose "*** OSDComputerName = $newname"
        Write-Verbose "*** OSDDomainOUName = $oupath"
        Write-Verbose "*** DEPTCODE   = $($Script:DeptCode)"
        Write-Verbose "*** FORMFACTOR = $ffcode"
    }
    Write-Output 0
}
catch {
    Write-Output -1
}
