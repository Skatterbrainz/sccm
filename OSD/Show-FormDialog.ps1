[CmdletBinding()]
param (
    [parameter()][string] $DefaultDept = "ITS",
    [parameter()][string[]] $DeptList = @('ACC','ADM','ENG','EXE','FIN','HRS','ITS','MKT','SLS'),
    [parameter()][string] $WorkstationPrefix = "D",
    [parameter()][string] $LaptopPrefix = "L",
    [parameter()][int] $MaxSerialNumLength = 8
)

function Get-FormFactorCode {
	[CmdletBinding()]
    param ()
    $cff = $(Get-CimInstance -ClassName Win32_SystemEnclosure -Namespace root\cimv2).ChassisTypes
	# ignore docks/port replicators which return an array rather than one value
    if ($cff.Count -gt 1) {
        $cff = $cff[0]
        Write-Verbose "*** filtering out duplicate for external device"
    }
    Write-Verbose "*** chassis type = $cff"
    # as of Q1-2018, codes are from 1 to 36
    # see https://blogs.technet.microsoft.com/brandonlinton/2017/09/15/updated-win32_systemenclosure-chassis-types/
    # desktops
    if ($cff -in (3..7)+(13,34,35)) { $ff = $WorkstationPrefix }
    # laptops
    elseif ($cff -in (10,11,12,14)+(15..30)+(31,32,33,36)) { $ff = $LaptopPrefix }
    # servers, but whatever, I do what I want!
    elseif ($cff -in (17..24)) { $ff = $WorkstationPrefix }
    # unknown
    else { $ff = $WorkstationPrefix }
    Write-Output $ff
}

$ffcode = Get-FormFactorCode
$sn     = (Get-CimInstance -ClassName Win32_SystemEnclosure).SerialNumber
$model  = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
$nic    = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | ? {$_.IPEnabled -eq $True}
$mac    = $nic.MACAddress
$ip     = $nic.IPAddress[0]
$gw     = $nic.DefaultIPGateway
Write-Verbose "serialNumber.... $sn"
if ($sn.Length -gt $MaxSerialNumLength) {
    $sn = $sn.Substring($sn.Length - $MaxSerialNumLength)
    Write-Verbose "trimmedSN....... $sn"
}
Write-Verbose "model........... $model"
Write-Verbose "formFactor...... $ffcode"
Write-Verbose "macAddress...... $mac"
Write-Verbose "ipAddress....... $ip"
Write-Verbose "ipGateway....... $gw"

Write-Verbose "defining WPF form"

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$TextFont = 'Microsoft Sans Serif,10'

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,350'
$Form.text                       = "New Computer Name"
$Form.TopMost                    = $false

$Label_Dept                      = New-Object system.Windows.Forms.Label
$Label_Dept.text                 = "Dept"
$Label_Dept.AutoSize             = $true
$Label_Dept.width                = 25
$Label_Dept.height               = 10
$Label_Dept.location             = New-Object System.Drawing.Point(40,40)
$Label_Dept.Font                 = $TextFont

$Label_Form                      = New-Object system.Windows.Forms.Label
$Label_Form.text                 = "Form"
$Label_Form.AutoSize             = $true
$Label_Form.width                = 25
$Label_Form.height               = 10
$Label_Form.location             = New-Object System.Drawing.Point(110,40)
$Label_Form.Font                 = $TextFont

$Label_Num                       = New-Object system.Windows.Forms.Label
$Label_Num.text                  = "Serial Num"
$Label_Num.AutoSize              = $true
$Label_Num.width                 = 25
$Label_Num.height                = 10
$Label_Num.location              = New-Object System.Drawing.Point(160,40)
$Label_Num.Font                  = $TextFont

$Label_Sfx                       = New-Object system.Windows.Forms.Label
$Label_Sfx.text                  = "Suffix"
$Label_Sfx.AutoSize              = $true
$Label_Sfx.width                 = 25
$Label_Sfx.height                = 10
$Label_Sfx.location              = New-Object System.Drawing.Point(260,40)
$Label_Sfx.Font                  = $TextFont

$Combo_Dept                      = New-Object system.Windows.Forms.ComboBox
$Combo_Dept.width                = 48
$Combo_Dept.height               = 20
$Combo_Dept.location             = New-Object System.Drawing.Point(40,64)
$Combo_Dept.Font                 = $TextFont
$Combo_Dept.text                 = $DefaultDept

$Text_Form                       = New-Object system.Windows.Forms.TextBox
$Text_Form.multiline             = $false
$Text_Form.text                  = $ffcode
$Text_Form.width                 = 27
$Text_Form.height                = 20
$Text_Form.location              = New-Object System.Drawing.Point(110,64)
$Text_Form.Font                  = $TextFont
$Text_Form.Enabled               = $false

$Text_Num                        = New-Object system.Windows.Forms.TextBox
$Text_Num.multiline              = $false
$Text_Num.text                   = $sn
$Text_Num.width                  = 84
$Text_Num.height                 = 20
$Text_Num.location               = New-Object System.Drawing.Point(160,64)
$Text_Num.Font                   = $TextFont

$Text_Sfx                        = New-Object system.Windows.Forms.TextBox
$Text_Sfx.multiline              = $false
$Text_Sfx.width                  = 54
$Text_Sfx.height                 = 20
$Text_Sfx.location               = New-Object System.Drawing.Point(260,64)
$Text_Sfx.Font                   = $TextFont

$Continue_Button                 = New-Object system.Windows.Forms.Button
$Continue_Button.text            = "Continue"
$Continue_Button.width           = 120
$Continue_Button.height          = 27
$Continue_Button.location        = New-Object System.Drawing.Point(146,186)
$Continue_Button.Font            = $TextFont

$DeptList | ForEach-Object {[void] $Combo_Dept.Items.Add($_)}

$Label_Model                     = New-Object System.Windows.Forms.Label
$Label_Model.location            = New-Object System.Drawing.Point(55,120)
$Label_Model.Height              = 27 
$Label_Model.Width               = 350 
$Label_Model.text                = "Model... $model" 
$Label_Model.Font                = "Courier New,11" 

$Label_Serial                    = New-Object system.Windows.Forms.Label
$Label_Serial.location           = New-Object System.Drawing.Point(55,145)
$Label_Serial.Height             = 27 
$Label_Serial.Width              = 350 
$Label_Serial.text               = "Serial.. $sn" 
$Label_Serial.Font               = "Courier New,11" 

$Label_Mac                       = New-Object System.Windows.Forms.Label
$Label_Mac.location              = New-Object System.Drawing.Point(55,170)
$Label_Mac.Height                = 27 
$Label_Mac.Width                 = 350
$Label_Mac.text                  = "MAC..... $mac" 
$Label_Mac.Font                  = "Courier New,11" 

$Label_IP                        = New-Object System.Windows.Forms.Label
$Label_IP.location               = New-Object System.Drawing.Point(55,195)
$Label_IP.Height                 = 27
$Label_IP.Width                  = 350
$Label_IP.text                   = "IP...... $ip" 
$Label_IP.Font                   = "Courier New,11" 

$Label_GW                        = New-Object System.Windows.Forms.Label
$Label_GW.location               = New-Object System.Drawing.Point(55,220)
$Label_GW.Height                 = 27
$Label_GW.Width                  = 350
$Label_GW.text                   = "Gateway. $gw" 
$Label_GW.Font                   = "Courier New,11" 

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Continue"
$Button1.width                   = 120
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(145,280)
$Button1.Font                    = 'Microsoft Sans Serif,10'

$Tip_Dept                        = New-Object system.Windows.Forms.ToolTip
$Tip_Dept.ToolTipTitle           = "Department"
$Tip_Dept.isBalloon              = $false

$Tip_Dept.SetToolTip($Combo_Dept,'Select Department Code')

Write-Verbose "building form content"
$Form.controls.AddRange(@($Label_Dept,$Label_Form,$Label_Num,$Label_Sfx,$Combo_Dept,$Text_Form,$Text_Num,$Text_Sfx,$Label_Model,$Label_Serial,$Label_Mac,$Label_IP,$Label_GW,$Button1))
$Combo_Dept.Add_SelectedValueChanged({ 
    $Script:DeptCode = $Combo_Dept.SelectedItem.ToString()
    Write-Host "selected dept changed to $DeptCode"
})
$Button1.Add_Click({ 
    $Script:sfx = $Text_Sfx.text
    $Form.Close() 
})

Write-Verbose "displaying form"
[void]$Form.ShowDialog()

if ([string]::IsNullOrEmpty($DeptCode)) {
    $DeptCode = $DefaultDept
}
if (![string]::IsNullOrEmpty($sfx)) {
    Write-Output "$DeptCode`-$ffcode`-$sn`-$sfx"
}
else {
    Write-Output "$DeptCode`-$ffcode`-$sn"
}
