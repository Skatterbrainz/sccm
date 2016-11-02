function Get-CmSiteInstallPath {
	param (
		[parameter(Mandatory=$False)] [string] $ComputerName = ""
	)
	if ($ComputerName -ne "") {
		$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
		$regKey = $Reg.OpenSubKey("SOFTWARE\Microsoft\SMS\setup")
		$regKey.GetValue("Installation Directory")
	}
	else {
		$x = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\setup"
		$x.'Installation Directory'
	}
}