Function Get-OSComputerOU {
    param( $ComputerName = $env:COMPUTERNAME )
    $Filter = "(&(objectCategory=Computer)(Name=$ComputerName))"
    $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
    $DirectorySearcher.Filter = $Filter
    $SearcherPath = $DirectorySearcher.FindOne()
    $DistinguishedName = $SearcherPath.GetDirectoryEntry().DistinguishedName
    $OUName = ($DistinguishedName.Split(","))[1]
    return $OUName.SubString($OUName.IndexOf("=")+1)
}
