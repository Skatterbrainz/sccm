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
    param (
        [parameter(Mandatory=$True, HelpMessage="Build Number")]
        [ValidateNotNullOrEmpty()]
        [string] $BuildNumber
    )
    $uri = 'https://www.systemcenterdudes.com/sccm-2012-version-numbers/'
    $raw = (New-Object System.Net.WebClient).DownloadString($uri)
    $raw = $raw.Replace("`n"," ")

    $start = $raw.IndexOf('class="tablepress tablepress-id-1">')
    $content = $raw.Substring($start+42)
    $end = $content.IndexOf('</tbody>')
    $content = $content.Substring(0, $end)
    $data = $content -replace "</td>",""
    $data = $data -replace "</tr>",""
    $data = $data -split "td class"

    foreach ($row in $data) {
        if ($row.StartsWith('="column-1"')) {
            $name = ($row.Substring(12)) -replace '<', ''
        }
        elseif ($row.StartsWith('="column-2"')) {
            $ver = ($row.Substring(12)) -replace '<', ''
        }
        if ($BuildNumber -eq $ver) {
            Write-Output $name
            break
        }
    }
}
