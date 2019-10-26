[CmdletBinding()]
param (
  [parameter()][ValidateLength(1,1)][string] $DriveLetter = "E",
  [parameter()][ValidateNotNullOrEmpty()][string]$InputFile = "folders.txt",
  [parameter()][ValidateNotNullOrEmpty()][string]$RootFolder = "SOURCES"
)
$ErrorActionPreference = 'stop'
try {
    $rootPath = "$DriveLetter`:\$RootFolder"
    if (!(Test-Path $rootPath)) { 
        mkdir $rootPath -Force 
        Write-Verbose "created folder: $rootPath"
    }
    $folders = Get-Content $InputFile
    foreach ($folder in $folders) {
        $fpath = Join-Path -Path $rootPath -ChildPath $folder
        if (!(Test-Path $fpath)) {
            mkdir $fpath -Force 
            Write-Verbose "created folder: $fpath"
        }
        else {
            Write-Verbose "folder exists: $fpath"
        }
    }
    $shareName = "$RootFolder`$"
    if ($shareName -notin (Get-SmbShare).Name) {
        Write-Verbose "creating share: $shareName"
        New-SmbShare -Path $rootPath -Name "$shareName"
    }
    Write-Host "finished processing"
}
catch {}
