param (
    [parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $IPAddress
)
$ports = @(80,443,1433,10123)
if (Test-Connection -ComputerName $IPAddress -Count 1 -TimeToLive 1 -Quiet) {
    Write-Host "Host is online" -ForegroundColor Green
    foreach ($port in $ports) {
        try {
            $test = New-Object System.Net.Sockets.TcpClient("$IPAddress", "$port") -ErrorAction Stop
            Write-Host "Port is open: $port" -ForegroundColor Green
        }
        catch {
            Write-Host "Port not accessible: $port" -ForegroundColor DarkRed
        }
    }
}
else {
    Write-Host "Host is not online: $IPAddress" -ForegroundColor DarkMagenta
}
