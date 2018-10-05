[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr DB Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName = "hcidalas37.hci.pvt",
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode = "HHQ",
    [parameter(Mandatory=$False, HelpMessage="Path to query files")]
        [ValidateNotNullOrEmpty()]
        [string] $QPath = ".\queries",
    [parameter(Mandatory=$False)]
        [ValidateSet('Grid','Csv','Pipeline')]
        [string] $Output = 'Grid'
)
$DatabaseName = "CM_$SiteCode"

$qfiles = Get-ChildItem -Path $QPath -Filter "*.sql" | Sort-Object Name
Write-Verbose "$($qfiles.count) files were found"
if ($qfiles.count -lt 1) {
    Write-Warning "$qpath contains no .sql files"
    break
}

Write-Verbose "display list in gridview for user to select"

$qfile = $qfiles | Select -ExpandProperty Name | 
    Out-GridView -Title "Select Query to Run" -OutputMode Single

if (![string]::IsNullOrEmpty($qfile)) {
    Write-Verbose "selected: $qfile"
    $qpath = Join-Path -Path $qpath -ChildPath $qfile
    Write-Verbose "filepath: $qpath"
    $qtext = Get-Content -Path $qpath
    if (![string]::IsNullOrEmpty($qtext)) {
        $QueryTimeout = 120
        $ConnectionTimeout = 30
        Write-Verbose "QUERY: $qtext"
        #Action of connecting to the Database and executing the query and returning results if there were any.
        $conn = New-Object System.Data.SqlClient.SQLConnection
        $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
        $conn.ConnectionString = $ConnectionString
        $conn.Open()
        $cmd = New-Object System.Data.SqlClient.SqlCommand($qtext,$conn)
        $cmd.CommandTimeout = $QueryTimeout
        $ds = New-Object System.Data.DataSet
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        [void]$da.Fill($ds)
        $conn.Close()
        $rowcount = $($ds.Tables).Rows.Count
        if ($rowcount -gt 0) {
            Write-Host "$rowcount rows returned" -ForegroundColor Green
            switch ($Output) {
                'Grid' {
                    $($ds.Tables).Rows | Out-GridView -Title "Query Results: $($qfile -replace '.sql','')"
                    break
                }
                'Csv' {
                    $($ds.Tables).Rows | Export-Csv -NoTypeInformation -Path "$($qfile -replace '.sql','.csv')"
                    break
                }
                default {
                    $($ds.Tables).Rows
                }
            } # switch
        }
        else {
            Write-Host "No rows were returned" -ForegroundColor Magenta
        }
    }
    else {
        Write-Warning "$qfile is empty"
    }
}
