param (
	[parameter(Mandatory=$True)] [string] $DeploymentShareNTFS,
	[parameter(Mandatory=$True)] [string] $DeploymentShareName,
	[parameter(Mandatory=$True)] [string] $CaptureAccount
)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oops, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
    Write-Warning "Aborting script..."
    Break
}
 
# Configure NTFS Permissions for the MDT Build Lab deployment share
icacls $DeploymentShareNTFS /grant '"Users":(OI)(CI)(RX)'
icacls $DeploymentShareNTFS /grant '"Administrators":(OI)(CI)(F)'
icacls $DeploymentShareNTFS /grant '"SYSTEM":(OI)(CI)(F)'
icacls "$DeploymentShareNTFS\Captures" /grant ""$CaptureAccount":(OI)(CI)(M)"
 
# Configure Sharing Permissions for the MDT Build Lab deployment share
# Note: Original uses "Change" rather than "Full"
Grant-SmbShareAccess -Name $DeploymentShareName -AccountName "EVERYONE" -AccessRight Full -Force
Revoke-SmbShareAccess -Name $DeploymentShareName -AccountName "CREATOR OWNER" -Force
