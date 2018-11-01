[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="Name of Collection")]
        [string] $CollectionName = "",
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr SQL Server Hostname")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode,
    [parameter(Mandatory=$False, HelpMessage="Type of Collection")]
        [ValidateSet('Device','User')]
        [string] $CollectionType = 'Device',
    [parameter(Mandatory=$False, HelpMessage="Wildcard filter on Collection Names list")]
        [switch] $Like
)
$DatabaseName = "CM_$SiteCode"
$QueryTimeout = 120
$ConnectionTimeout = 30
$conn = New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString = $ConnectionString
try {
    $conn.Open()
    Write-Verbose "connection opened successfully"
}
catch {
    Write-Error $_.Exception.Message
    break
}
$query = "SELECT DISTINCT CollectionID, Name, MemberCount FROM dbo.v_Collection"

if ([string]::IsNullOrEmpty($CollectionName)) {
    $query += " ORDER BY Name"
}
else {
    if ($Like) {
        $query += " WHERE Name LIKE '$CollectionName`%'"
    }
    else {
        $query += " WHERE Name='$CollectionName'"
    }
}
Write-Verbose "query: $query"
$cmd = New-Object System.Data.SqlClient.SqlCommand($query,$conn)
$cmd.CommandTimeout = $QueryTimeout
$ds = New-Object System.Data.DataSet
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.Fill($ds)
$conn.Close()

$rowcount = $($ds.Tables).Rows.Count
Write-Verbose "$rowcount rows returned"

if ($rowcount -gt 0) {
    Write-Host "$rowcount collections returned" -ForegroundColor Cyan
    if ([string]::IsNullOrEmpty($CollectionName)) {
        $x = $($ds.Tables).Rows | Out-GridView -Title "Select Collection" -OutputMode Single
        if ($x) {
            Write-Verbose "name: $($x | Select -ExpandProperty Name)"
            Write-Output $($x | Select -ExpandProperty CollectionID)
        }
        else {
            Write-Warning "No selection made"
            break
        }
    }
    else {
        if (!$Like) {
            $x = $($ds.Tables).Rows[0]
            Write-Verbose "name: $CollectionName"
            Write-Output $($x | Select -ExpandProperty CollectionID)
        }
        else {
            $x = $($ds.Tables).Rows | Out-GridView -Title "Select Collection" -OutputMode Single
            if ($x) {
                Write-Verbose "name: $($x | Select -ExpandProperty Name)"
                Write-Output $($x | Select -ExpandProperty CollectionID)
            }
            else {
                Write-Warning "No selection made"
                break
            }
        }
    }
}
