  
function Get-NetworkInfo {
    param (
        [parameter(Mandatory=$True)]
        [string] $ComputerName
    )
    $x = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $ComputerName |
            Select Description, MACAddress, IPAddress

    foreach($nic in $x) {
        if ($($nic.IPAddress).Count -gt 0) {
            $ip = $nic.IPAddress[0]
        }
        else {
            $ip = ""
        }
        $props = [ordered]@{
           Description = $nic.Description
           MACAddress  = $nic.MACAddress
           IPAddress   = $ip
        }
        New-Object PSObject -Property $props
    }
}
