# thanks to https://www.powershellmagazine.com/2013/04/23/pstip-get-the-ad-site-name-of-a-computer/
function Get-ComputerAdSite {
    [CmdletBinding()]
    param (
        [parameter()] [ValidateNotNullOrEmpty()] [string] $ComputerName = $env:COMPUTERNAME
    )
    $site = nltest /server:$ComputerName /dsgetsite 2>$null
    if($LASTEXITCODE -eq 0){ $site[0] }
}
