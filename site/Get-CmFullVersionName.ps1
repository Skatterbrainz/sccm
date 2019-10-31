function Get-CmFullVersionName {
	<#
	.SYNOPSIS
		Get ConfigMgr Version Name from Build Number
	.DESCRIPTION
		Returns full ConfigMgr version name from Build Number string
	.PARAMETER BuildNumber
		Version build number, such as '5.0.8540.1611'
	.EXAMPLE
		Get-CmFullVersionName -BuildNumber '5.0.8540.1611'
		Returns: "SCCM 1706 - Update to Rollup 1 (KB4042949)"
	.NOTES
		Ugly AF and Crude, but usually works okay
		Thanks to System Center Dudes web site for the published data table
	.OUTPUT
		String containing full version name, or $null if no match
	#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True, ValueFromPipeline=$True, HelpMessage="ConfigMgr Build Number")]
        [ValidateNotNullOrEmpty()]
        [string] $BuildNumber
    )
    $uri = 'https://www.systemcenterdudes.com/sccm-2012-version-numbers/'
    try {
        Write-Verbose "Reading: $uri"
        $raw = (New-Object System.Net.WebClient).DownloadString($uri)
        Write-Verbose "HTML data source imported successfully"
    }
    catch {
        Write-Error $_.Exception.HelpMessage
        break
    }
    $raw = $raw.Replace("`n"," ")
    # get rough starting point to snatch table data
    $start = $raw.IndexOf('class="tablepress tablepress-id-1">')
    $content = $raw.Substring($start+42)
    # get ending point to trim off excess trailing data
    $end = $content.IndexOf('</tbody>')
    # trim data to get just the desired table, oh, that big juicy table
    $content = $content.Substring(0, $end)
    $data = $content -replace "</td>",""
    $data = $data -replace "</tr>",""
    $data = $data -split "td class"
    # you're probably laughing right about here, but that's okay
    foreach ($row in $data) {
        if ($row.StartsWith('="column-1"')) {
            $name = ($row.Substring(12)) -replace '<', ''
        }
        elseif ($row.StartsWith('="column-2"')) {
            $ver = ($row.Substring(12)) -replace '<', ''
        }
        # okay, by now, you're probably angry, that's okay too
        Write-Verbose "NAME: $name // VERSION: $ver"
        if ($BuildNumber -eq $ver) {
            Write-Output $name
            break
        }
    }
    # phew! you made it!
}
