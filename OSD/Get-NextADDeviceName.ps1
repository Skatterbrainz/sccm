function Get-NextADDeviceName {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $URI,
        [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SecretKey,
        [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Prefix,
        [parameter()][ValidateRange(3,15)][int] $NameLength = 4
    )
    try {
        Write-Verbose "connecting to web service at $URI"
        $ws = New-WebServiceProxy -Uri $URI -ErrorAction 'stop'
        for ($index = 1; $index -lt 100; $index++) {
            $nextname = $Prefix + $([string]$index).PadLeft($NameLength - $($Prefix.Length), "0")
            Write-Verbose "checking name: $nextname"
            $found = ($ws.GetADComputer($SecretKey, $nextname)).SamAccountName
            if (![string]::IsNullOrEmpty($found)) {
                Write-Verbose "name exists: $nextname"
            }
            else {
                return $nextname
            }
        }
        Write-Output "no names for this prefix available from 1 to 100"
    }
    catch {
        Write-Error $_.Exception.Message 
    }
}

$newname = Get-NextADDeviceName
try {
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $tsenv.Value("OSDComputerName") = $newname
}
catch {
    Write-Warning "not running in a task sequence at the moment"
}