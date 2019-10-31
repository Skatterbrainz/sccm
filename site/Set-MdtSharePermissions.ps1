<#
.SYNOPSIS
  Configure security and share permissions for MDT deployment share
.PARAMETER DeploymentShareNTFS
  [string] (required) NTFS file path for deployment share
.PARAMETER DeploymentShareName
  [string] (required) Name of deployment name share
.PARAMETER CaptureAccount
  [string] (required) name of MDT build/capture account
.NOTES
  adapted slightly from https://deploymentresearch.com/Research/Post/518/Fixing-MDT-2013-Update-1-deployment-share-permissions-using-PowerShell
#>

param (
	[parameter(Mandatory=$True)] 
    [ValidateNotNullOrEmpty()]
    [string] $DeploymentShareNTFS,
	[parameter(Mandatory=$True)] 
    [ValidateNotNullOrEmpty()]
    [string] $DeploymentShareName,
	[parameter(Mandatory=$True)] 
    [ValidateNotNullOrEmpty()]
    [string] $CaptureAccount
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
