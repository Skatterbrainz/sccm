function Get-CmSiteDBInstance {
	param (
		[parameter(Mandatory=$False)] [string] $ComputerName = ""
	)
	if ($ComputerName -ne "") {
		$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
		$regKey = $Reg.OpenSubKey("SOFTWARE\Microsoft\SMS\SQL Server")
		$regKey.GetValue("Service Name")
	}
	else {
		$x = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\SQL Server"
		$x.'Service Name'
	}
}