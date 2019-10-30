[CmdletBinding()]
param(
    [parameter()][ValidateNotNullOrEmpty()][string]$InputFile = "downloads.txt",
    [parameter()][ValidateNotNullOrEmpty()][string]$rootPath = "E:\SOURCES"
)
try {
    $apps = Get-Content $InputFile
    foreach ($app in $apps) {
        $appdata   = $app -split '~'
        $appPath   = $appdata[0]
        $appSource = $appdata[1]
        if ($appdata.Count -eq 3) {
            $filename = $appdata[2]
        }
        else {
            $filename  = $($appSource -split '/' | select -Last 1) -replace '%20','_'
        }
        $destPath  = Join-Path -Path $rootPath -ChildPath $appPath
        if (!(Test-Path $destPath)) { 
            mkdir $destPath -Force 
            Write-Verbose "created folder: $destPath"
        }
        $destination = Join-Path -Path $destPath -ChildPath "$filename"
        if (!(Test-Path $destination)) {
            #Invoke-WebRequest -Uri $appSource -OutFile $destination
            [void](New-Object System.Net.WebClient).DownloadFile($appSource, $destination)
        }
        else {
            Write-Verbose "file exists: $destination"
        }
    }
    Write-Host "finished processing"
}
catch {
    Write-Error $_.Exception.Message 
}
