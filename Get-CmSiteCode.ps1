<#
.EXAMPLE
  Get-CmSiteCode -ComputerName "cm01.contoso.com"
#>

function Get-CmSiteCode {
  param (
    [parameter(Mandatory=$False)] [string] $ComputerName = ""
  )
  if ($ComputerName -ne "") {
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
    $regKey = $Reg.OpenSubKey("SOFTWARE\Microsoft\SMS\Identification")
    $regKey.GetValue("Site Code")
  }
  else {
    $x = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\Identification"
    $x.'Site Code'
  }
}