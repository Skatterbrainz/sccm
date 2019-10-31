[CmdletBinding()]
param (
  [parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $CollectionID,
  [parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $InputFile,
  [parameter(Mandatory=$False)]
    [switch] $DeepInspect,
  [parameter(Mandatory=$False)]
    [switch] $ShowReverse
)
$members = .\Get-CmCollectionMembers.ps1 -CollectionID $CollectionID
$memberNames = $members | Select -ExpandProperty ComputerName
$computerlist = Get-Content -Path $InputFile

foreach ($cn in $computerlist) {
    if ($DeepInspect) {
        try {
            Write-Verbose "connecting to: $cn (deep)"
            $x = Test-NetConnection -ComputerName $cn -WarningAction SilentlyContinue
            if ($x.PingSucceeded) {
                $stat = "ONLINE"
            }
            elseif ($x.RemoteAddress) {
                $stat = "OFFLINE"
            }
            else {
                $stat = "NO DNS"
            }
        }
        catch {
            $stat = "ERROR"
        }
    }
    else {
        Write-Verbose "connecting to: $cn"
        if (Test-NetConnection -ComputerName $cn -InformationLevel Quiet) {
            $stat = "ONLINE"
        }
        else {
            $stat = "OFFLINE"
        }
    }
    if ($memberNames -notcontains $cn) {
        $ismember = $False
        Write-Verbose "$cn is not in collection"
    }
    else {
        $ismember = $True
        Write-Verbose "$cn is ONLINE"
    }
    $data = [ordered]@{
        Computer = $cn
        IsOnline = $stat
        IsMember = $ismember
    }
    New-Object PSObject -Property $data
} # foreach

if ($ShowReverse) {
    foreach ($m in $members) {
        if ($computerlist -notcontains $m) {
            Write-Host "$m is not in file"
        }
    }
}
