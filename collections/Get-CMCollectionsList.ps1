function Get-CmCollectionsList {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [string] $CmDbHost,
        [parameter(Mandatory=$True)]
        [string] $CmSiteCode,
        [parameter(Mandatory=$False)]
        [ValidateSet('direct','query','all')]
        [string] $MembershipType = 'all'
    )
    switch ($MembershipType) {
        'all' {
            $query = 'SELECT DISTINCT dbo.v_Collection.CollectionID, dbo.v_Collection.Name, dbo.v_Collection.CollectionType 
            FROM dbo.v_Collection ORDER BY dbo.v_Collection.Name'
            break;
        }
        'query' {
            $query = 'SELECT DISTINCT dbo.v_CollectionRuleQuery.CollectionID, dbo.v_Collection.Name, dbo.v_Collection.CollectionType 
            FROM dbo.v_CollectionRuleQuery INNER JOIN dbo.v_Collection ON 
            dbo.v_CollectionRuleQuery.CollectionID = dbo.v_Collection.CollectionID 
            ORDER BY dbo.v_Collection.Name'
            break;
        }
        'direct' {
            $query = 'SELECT DISTINCT 
            dbo.v_Collection.CollectionID, dbo.v_Collection.Name, dbo.v_Collection.CollectionType 
            FROM dbo.v_Collection WHERE CollectionID NOT IN (
            SELECT DISTINCT CollectionID from dbo.v_CollectionRuleQuery) 
            ORDER BY dbo.v_Collection.Name'
            break;
        }
    }
    Write-Verbose "query: $query"
    try {
        $connection = New-Object -ComObject "ADODB.Connection"
        $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
        $connection.Open($connString);
        $IsOpen = $True
        Write-Verbose "connection is opened"
        $rs = New-Object -ComObject "ADODB.RecordSet"
        $rs.Open($query, $connection)
        Write-Verbose "recordset opened"
        while (!$rs.EOF) {
            Write-Verbose "reading recordset row..."
            $props = [ordered]@{
                CollectionID = $rs.Fields("CollectionID").value | Out-String
                Name = $rs.Fields("Name").value | Out-String
                Type = $rs.Fields("CollectionType").value | Out-String
            }
            New-Object PSObject -Property $props
            $rs.MoveNext()
        }
        Write-Verbose "closing recordset"
        $rs.Close
    }
    catch {
        if ($IsOpen -eq $True) { [void]$connection.Close() }
        throw "Error: $($Error[0].Exception.Message)"
    }
    finally {
        Write-Verbose "closing connection"
        if ($IsOpen -eq $True) { [void]$connection.Close() }
    }
}
