<#
.DESCRIPTION
  queries Internet web page to map version number to display name version
  for example 5.00.xxxx.xxxx --> "Current Branch YYMM"
.PARAMETER VersionNumber
  [required] (string) The base version number (e.g. "5.00.8455.1000")
#>
function Get-CmFullVersionName {
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[string] $VersionNumber
	)
	$weburl = "https://blogs.technet.microsoft.com/configmgrdogs/2014/02/07/configmgr-2012-version-numbers/"
  try {
  	$site  = Invoke-WebRequest -UseBasicParsing -Uri $weburl
  }
  catch {
    write-error "the internet just puked in your face!"
    break
  }
	$start = $site.Content.IndexOf("<tbody>") + 7
	$end   = $site.Content.IndexOf("</tbody>")
	$guts  = $site.Content
	$tablecontents = $guts.substring($start, $end-$start)

	$newtable = $tablecontents.Replace("<tr>","|")
	$newtable = $newtable.Replace("</tr>`n","")
	$newtable = $newtable.Replace("<td width=`"173`" valign=`"top`">","")
	$newtable = $newtable.Replace("<td width=`"128`" valign=`"top`">",",")
	$newtable = $newtable.Replace("<td width=`"98`" valign=`"top`">",",")
	$newtable = $newtable.Replace("</td>","")
	$newtable = $newtable.Replace("<p>","")
	$newtable = $newtable.Replace("</p>","")
	$newtable = $newtable.Replace("`n","")

	$rows = $newtable.split("|")
	$result = ""

	foreach ($row in $rows) {
		$cells = $row.Split(",")
		if ($cells[1] -eq $VersionNumber) {
			$result = $cells[0]
		}
	}
	return $result
}
