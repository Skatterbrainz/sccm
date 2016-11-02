$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

$data = Import-Csv -Path "$ScriptPath\BoundaryGroups.csv"

foreach ($row in $data) {
	$bname = $row.Name
	$desc  = $row.Description
	if ($desc -eq "") {
		$desc = $bname
	}
	$sitecode = $row.Site
	New-CmBoundaryGroup -Name $bname -Description $desc -DefaultSiteCode $sitecode
}
