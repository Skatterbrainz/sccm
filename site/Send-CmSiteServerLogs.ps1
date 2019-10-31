<#
.SYNOPSIS
    Send-CmSiteServerLogs.ps1 collects SCCM site server logs, compresses
    them into a tasty little chocolate-covered ZIP file, and sends it out
    through the vast and spacious Internet, using Gmail as the courier 
    pidgeon.

.DESCRIPTION
    The Synopsis should be enough.  Or maybe I'm doing this wrong?

.PARAMETER SendFrom
    [string] (required) sender's email address

.PARAMETER SendTo
    [string] (required) recipient's email address

.PARAMETER LogFilter
    [string] (optional) wildcard pattern for collecting only a subset
    of log files to send.  Example "w*"

.NOTES
    Author..... skattebrainz.wordpress.com / GitHub / Twitter
    Created.... 10/27/2016
    Modified...
    Support.... 800.555.1212

    USE AT YOUR OWN RISK. AUTHOR IS NOT RESPONSIBLE FOR FLYING BODY PARTS.
#>

param (
    [parameter(Mandatory=$True)] [string] $SendFrom,
    [parameter(Mandatory=$True)] [string] $SendTo,
    [parameter(Mandatory=$False)] [string] $LogFilter = ""
)

$smtp = "smtp.gmail.com"
$port = 587
$Subject = "SCCM Log Sender`: $($env:COMPUTERNAME)"

$temp = $env:TEMP

if ($SendMail) {
    $cred = Get-Credential -Message "Provide credentials to use SMTP service" -UserName $SendFrom
}

<#
.SYNOPSIS
    Get-CmSiteInstallPath returns [string] path to the base installation
    of System Center Configuration Manager on the site server.
.DESCRIPTION
    Returns the full SCCM installation path using a registry query.
.NOTES
#>

function Get-CmSiteInstallPath {
	$x = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\setup"
	$x.'Installation Directory'
}

# begin the assault!

$cminst = Get-CmSiteInstallPath

if ($cminst -ne $null) {
    $cmlogpath = "$cminst\logs"
    if (Test-Path $cmlogpath) {
        Write-Output "Backing up site server log files..."
        $src = "$temp\logtemp"
        if (Test-Path $src) {
            Write-Output "Removing previous temp folder..."
            rd $src -Recurse -Force
        }
        md $src
        if ($LogFilter -ne "") {
            Write-Output "Filtering logs: $LogFilter.log"
            copy "$cmlogpath\$LogFilter.log" "$src"
            $cmlogs = Get-ChildItem -Path $src -Filter "$LogFilter.log"
        }
        else {
            copy "$cmlogpath\*.log" "$src"
            $cmlogs = Get-ChildItem -Path $src -Filter "*.log"
        }
        $lc = $cmlogs.Length
        $dest = "$temp\sccmlogs.zip"
        if (Test-Path $dest) {
            Write-Output "Removing previous archive file..."
            del $dest -Force
        }
        Write-Output "Compressing backup log files..."
        Add-Type -AssemblyName "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory($src,$dest)
        if (Test-Path "$dest") {
            $size = $(Get-Item -Path "$dest").Length
            $size = [math]::Round($size / 1MB,2)
            Write-Output "Archive created: $dest ($size MB)"
            if ($SendMail) {
                $Message = "Sending $lc SCCM Log files"
                Write-Output "Sending email with zip attachment..."
                Send-MailMessage -Subject "$Subject" -Body "$Message" -From $SendFrom -To $SendTo -SmtpServer $smtp -Attachments "$dest" -Port $Port -UseSsl -Credential $cred
            }
            Write-Output "finished!"
        }
        else {
            Write-Output "error: unable to create archive"
        }
    }
    else {
        Write-Output "error: unable to locate logs folder"
    }
}
else {
    Write-Output "error: SCCM installation path not found."
}
