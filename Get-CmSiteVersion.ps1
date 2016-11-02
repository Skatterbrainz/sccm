<#
.EXAMPLE
  Get-CmSiteVersion -ComputerName "cm01.contoso.com"
#>

function Get-CmSiteVersion {
  param (
    [parameter(Mandatory=$False)] [string] $ComputerName = ""
  )
  if ($ComputerName -ne "") {
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
    $regKey = $Reg.OpenSubKey("SOFTWARE\Microsoft\SMS\setup")
    $regKey.GetValue("Full Version")
  }
  else {
    $x = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\setup"
    $x.'Full Version'
  }
}