Import-Module WebAdministration
$certCount = 0
Get-ChildItem -Path IIS:SSLBindings | ForEach-Object -Process `
{
    if ($_.Sites)
    {
        $cert = Get-ChildItem -Path CERT:LocalMachine/My |
            Where-Object -Property Thumbprint -EQ -Value $_.Thumbprint

        if($cert) {$certCount++}

    }
}
$certCount