<#
.DESCRIPTION
    Display ConfigMgr collections in grid view for selection
.PARAMETER AdoConnection
    ADO database connection object (opened)
.EXAMPLE
    $conn = Get-CmAdoConnection -SQLServerName "cm01.contoso.local" -DatabaseName "CM_P01" -SiteCode "P01"
    $collID = Select-CmCollectionFromList.ps1 -AdoConnection $conn
    $conn.Close()
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True)]
    [ValidateNotNull()]
    $AdoConnection
)
$QueryTimeout = 120
$query = "SELECT DISTINCT CollectionID, Name, MemberCount FROM dbo.v_Collection ORDER BY Name"
$cmd = New-Object System.Data.SqlClient.SqlCommand($query,$AdoConnection)
$cmd.CommandTimeout = $QueryTimeout
$ds = New-Object System.Data.DataSet
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.Fill($ds)
$rowcount = $($ds.Tables).Rows.Count
if ($rowcount -gt 0) {
    Write-Verbose "$rowcount collections returned"
    try {
        $x = $($ds.Tables).Rows | Out-GridView -Title "Select Collection" -OutputMode Single
        Write-Output $x | Select-Object -ExpandProperty CollectionID
    }
    catch {
        Write-Error $Error[0].Exception.Message
    }
}
