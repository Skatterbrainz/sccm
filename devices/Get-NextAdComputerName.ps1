function Get-NextAdComputerName {
    param ($Prefix, $Digits)
    $clist = Get-ADComputer -Filter * -Properties Name -ErrorAction SilentlyContinue| 
        ?{$_.Name -match "$Prefix[0-9]{$Digits}"} | 
            Select -ExpandProperty Name |
                Sort Name
    if ($clist.Count -gt 0) {
        $n = $clist.Count
        [int]$x = [convert]::ToInt32($clist[$n-1].Replace($Prefix,""),10)
        [string]$next = $x + 1
        while ($next.Length -lt $Digits) {
            $next = "0" + $next
        }
    }
    $($Prefix + $next)
}