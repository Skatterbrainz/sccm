<#
.SYNOPSIS
    Export-CM-Healthcheck.ps1 reads the output from Get-CM-Inventory.ps1 to generate a
    final report using Microsoft Word (2010, 2013, 2016)

.DESCRIPTION
    Export-CM-Healthcheck.ps1 reads the output from Get-CM-Inventory.ps1 to generate a
    final report using Microsoft Word (2010, 2013, 2016)

.PARAMETER ReportFolder
    [string] [required] Path to output data folder

.PARAMETER

.NOTES
    Version 0.1 - Raphael Perez - 24/10/2013 - Initial Script
    Version 0.2 - Raphael Perez - 05/11/2014
        - Added Get-MessageInformation and Get-MessageSolution
    Version 0.3 - Raphael Perez - 22/06/2015
        - Added ReportSection
    Version 0.4 - Raphael Perez - 04/02/2016
        - Fixed issue when executing on a Windows 10 machine
    Version 0.5 - David Stein (4/10/2017)
        - Added support for MS Word 2016
        - Changed "cm12R2healthCheck.xml" to "cmhealthcheck.xml"
        - Detailed is now a [switch] not a [boolean]
        - Added params for CoverPage, Author, CustomerName, etc.
        - Bugfixes for Word document builtin properties updates
        - Minor bugfixes throughout

    Thanks to:
    Base script (the hardest part) created by Rafael Perez (www.rflsystems.co.uk)
    Word functions copied from Carl Webster (www.carlwebster.com)
    Word functions copied from David O'Brien (www.david-obrien.net/2013/06/20/huge-powershell-inventory-script-for-configmgr-2012/)

.EXAMPLE
    Option 1: powershell.exe -ExecutionPolicy Bypass .\Export-CM-Healthcheck.ps1 [Parameters]
    Option 2: Open Powershell and execute .\Export-CM-Healthcheck.ps1 [Parameters]

#>

PARAM (
    [Parameter (Mandatory = $True, HelpMessage = "Collected data folder")] 
        [ValidateNotNullOrEmpty()]
        [string] $ReportFolder,
	[Parameter (Mandatory = $False, HelpMessage = "Export full data, not only summary")] 
        [switch] $Detailed,
	[Parameter (Mandatory = $False, HelpMessage = "HealthCheck query file name")] 
        [string] $Healthcheckfilename = "cmhealthcheck.xml",
	[Parameter (Mandatory = $False, HelpMessage = "Debug more?")] 
        $Healthcheckdebug = $False,
    [parameter (Mandatory = $False, HelpMessage = "Word Template cover page name")] 
        [string] $CoverPage = "Slice (Light)",
    [parameter (Mandatory = $False, HelpMessage = "Customer company name")] 
        [string] $CustomerName = "Company",
    [parameter (Mandatory = $False, HelpMessage = "Author's full name")] 
        [string] $AuthorName = "Author",
    [parameter (Mandatory = $False, HelpMessage = "Overwrite existing report file")]
        [switch] $Overwrite
)

$FormatEnumerationLimit = -1
$bLogValidation = $False
$bAutoProps     = $True
$currentFolder  = $PWD.Path
$CopyrightName  = "En Pointe Technologies, a PCM Company"

if ($currentFolder.substring($currentFolder.length-1) -ne '\') { $currentFolder+= '\' }
if ($healthcheckdebug -eq $true) { $PSDefaultParameterValues = @{"*:Verbose"=$True}; $currentFolder = "C:\Temp\CMHealthCheck\" }
$logFolder = $currentFolder + "_Logs\"
if ($reportFolder.substring($reportFolder.length-1) -ne '\') { $reportFolder+= '\' }
$component = ($MyInvocation.MyCommand.Name -replace '.ps1', '')
$logfile = $logFolder + $component + ".log"
$Error.Clear()

#region functions

function Test-Powershell {
    param (
        [int] $version = 4
    )
    Write-Output ($PSVersionTable.psversion.Major -ge $version)
}

function Test-Powershell64bit {
    Write-Output ([IntPtr]::size -eq 8)
}

Function Write-Log {
    param (
        [String]$Message,
        [int]$severity = 1,
        [string]$logfile = '',
        [bool]$showmsg = $true
        
    )
    $TimeZoneBias = Get-WmiObject -Query "Select Bias from Win32_TimeZone"
    $Date  = Get-Date -Format "HH:mm:ss.fff"
    $Date2 = Get-Date -Format "MM-dd-yyyy"
    $type  = 1
    
    if (($logfile -ne $null) -and ($logfile -ne '')) {    
        "<![LOG[$Message]LOG]!><time=`"$date+$($TimeZoneBias.bias)`" date=`"$date2`" component=`"$component`" context=`"`" type=`"$severity`" thread=`"`" file=`"`">" | Out-File -FilePath $logfile -Append -NoClobber -Encoding default
    }
    
    if ($showmsg -eq $true) {
        switch ($severity) {
            3 { Write-Host $Message -ForegroundColor Red }
            2 { Write-Host $Message -ForegroundColor Yellow }
            1 { Write-Host $Message }
        }
    }
}

Function Test-Folder {
    param (
        [String]$Path,
        [bool]$Create = $true
    )
    if (Test-Path -Path $Path) { Write-Output $true }
    elseif ($Create -eq $true) {
        try {
            New-Item ($Path) -type directory -force | out-null
            Write-Output $true        	
        }
        catch {
            Write-Output $false
        }        
    }
    else { Write-Output $false }
}

function Get-MessageInformation {
    param (
		$MessageID
	)
	$msg = $MessagesXML.dtsHealthCheck.Message | Where-Object {$_.MessageId -eq $MessageID}
	if ($msg -eq $null) {
        Write-Output "Unknown Message ID $MessageID" 
    }
	else { 
        Write-Output $msg.Description 
    }
}

function Get-MessageSolution {
    param (
		$MessageID
	)
	$msg = $MessagesXML.dtsHealthCheck.MessageSolution | Where-Object {$_.MessageId -eq $MessageID}
	if ($msg -eq $null)	{ 
        Write-Output "There is no known possible solution for Message ID $MessageID" 
    }
	else { 
        Write-Output $msg.Description 
    }
}

function Write-WordText {
    param (
		$wordselection,
		$text    = "",
		$Style   = "No Spacing",
		$bold    = $false,
		$newline = $fals,
		$newpage = $false
	)
	
	$texttowrite = ""
	$wordselection.Style = $Style

    if ($bold) { $wordselection.Font.Bold = 1 } else { $wordselection.Font.Bold = 0 }
	$texttowrite += $text 
	$wordselection.TypeText($text)
	If ($newline) { $wordselection.TypeParagraph() }	
	If ($newpage) { $wordselection.InsertNewPage() }	
}

Function Set-WordDocumentProperty {
    param (
		$document,
		$name,
		$value
	)
    $document.BuiltInDocumentProperties($Name) = $Value
}

<# this function needs more testing #>

Function Add-WordDocumentProperty {
    param (
        $document,
        $name,
        $value
    )
    Write-Verbose "adding word doc property $name with value $value"
    $binding = â€œSystem.Reflection.BindingFlagsâ€ -as [type]
    $CustomProperty = $name
    [array]$ArrayArgs = $CustomProperty,$false,4,$value

    $CustomProps = $document.CustomDocumentProperties
    $typeCustPrp = $CustomProps.GetType()
    try {
        $prop = $typeCustPrp.InvokeMember("add",$binding::InvokeMethod,$null,$CustomProps,$arrayArgs) | Out-Null
    }
    catch [System.Exception] {
        Write-Verbose "failed to add custom property: $name"
    }
}

Function ReportSection {
    param (
		$HealthCheckXML,
        $section,
		$detailed = $false,
        $doc,
		$selection,
        $logfile
	)
	Write-Log -message "Starting Secion $section with detailed as $($detailed.ToString())" -logfile $logfile

	foreach ($healthCheck in $HealthCheckXML.dtsHealthCheck.HealthCheck) {
		if ($healthCheck.Section.tolower() -ne $Section) { continue }
		$Description = $healthCheck.Description -replace("@@NumberOfDays@@", $NumberOfDays)
		if ($healthCheck.IsActive.tolower() -ne 'true') { continue }
        if ($healthCheck.IsTextOnly.tolower() -eq 'true') {
            if ($Section -eq 5) {
                if ($detailed -eq $false) { 
                    $Description += " - Overview" 
                } 
                else { 
                    $Description += " - Detailed"
                }            
            }
			Write-WordText -wordselection $selection -text $Description -style $healthCheck.WordStyle -newline $true
			Continue;
		}
		
		Write-WordText -wordselection $selection -text $Description -style $healthCheck.WordStyle -newline $true
        $bFound = $false
        $tableName = $healthCheck.XMLFile
        if ($Section -eq 5) {
            if (!($detailed)) { 
                $tablename += "summary" 
            } 
            else { 
                $tablename += "detail"
            }            
        }

		foreach ($rp in $ReportTable) {
			if ($rp.TableName -eq $tableName) {
                $bFound = $true
				Write-Log -message (" - Exporting $($rp.XMLFile) ...") -logfile $logfile
				$filename = $rp.XMLFile				
				if ($filename.IndexOf("_") -gt 0) {
					$xmltitle = $filename.Substring(0,$filename.IndexOf("_"))
					$xmltile = ($rp.TableName.Substring(0,$rp.TableName.IndexOf("_")).Replace("@","")).Tolower()
					switch ($xmltile) {
						"sitecode"   { $xmltile = "Site Code: "; break; }
						"servername" { $xmltile = "Server Name: "; break; }
					}
					switch ($healthCheck.WordStyle) {
						"Heading 1" { $newstyle = "Heading 2"; break; }
						"Heading 2" { $newstyle = "Heading 3"; break; }
						"Heading 3" { $newstyle = "Heading 4"; break; }
						default { $newstyle = $healthCheck.WordStyle; break }
					}
					
					$xmltile += $filename.Substring(0,$filename.IndexOf("_"))

					Write-WordText -wordselection $selection -text $xmltile -style $newstyle -newline $true
				}				
				
	            if (!(Test-Path ($reportFolder + $rp.XMLFile))) {
					Write-WordText -wordselection $selection -text $healthCheck.EmptyText -newline $true
					Write-Log -message ("Table does not exist") -logfile $logfile -severity 2
					$selection.TypeParagraph()
				}
				else {
                    Write-Verbose "importing XML file: $filename"
	        		$datatable = Import-Clixml -Path ($reportFolder + $filename)
		            $count = 0
		            $datatable | Where-Object {$count++}
					
		            if ($count -eq 0) {
						Write-WordText -wordselection $selection -text $healthCheck.EmptyText -newline $true
						Write-Log -message ("Table: 0 rows") -logfile $logfile -severity 2
						$selection.TypeParagraph()
		                continue
		            }

					switch ($healthCheck.PrintType.ToLower()) {
						"table" {
                            Write-Verbose "writing table type: table"
							$Table = $Null
					        $TableRange = $Null
					        $TableRange = $doc.Application.Selection.Range
                            $Columns = 0
                            foreach ($field in $HealthCheck.Fields.Field) {
                                if ($section -eq 5) {
                                    if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
                                    elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
                                }
                                $Columns++
                            }

							$Table = $doc.Tables.Add($TableRange, $count+1, $Columns)
							$table.Style = $TableStyle

							$i = 1;
							Write-Log -message ("Table: $count rows and $Columns columns") -logfile $logfile

							foreach ($field in $HealthCheck.Fields.Field) {
                                if ($section -eq 5) {
                                    if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
                                    elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
                                }

								$Table.Cell(1, $i).Range.Font.Bold = $True
								$Table.Cell(1, $i).Range.Text = $field.Description
								$i++
	                        }
							$xRow = 2
							$records = 1
							$y=0
							foreach ($row in $datatable) {
								if ($records -ge 500) {
									Write-Log -message ("Exported $(500*($y+1)) records") -logfile $logfile
									$records = 1
									$y++
								}
								$i = 1;
								foreach ($field in $HealthCheck.Fields.Field) {
                                    if ($section -eq 5) {
                                        if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
                                        elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
                                    }

									$Table.Cell($xRow, $i).Range.Font.Bold = $false
									$TextToWord = "";
									switch ($field.Format.ToLower()) {
										"message" {
											$TextToWord = Get-MessageInformation -MessageID ($row.$($field.FieldName))
											break ;
										}
										"messagesolution" {
											$TextToWord = Get-MessageSolution -MessageID ($row.$($field.FieldName))
											break ;
										}										
										default {
											$TextToWord = $row.$($field.FieldName);
											break;
										}
									}
                                    if ([string]::IsNullOrEmpty($TextToWord)) { $TextToWord = " " }
									$Table.Cell($xRow, $i).Range.Text = $TextToWord.ToString()
									$i++
		                        }
								$xRow++
								$records++
							}

					        $selection.EndOf(15) | Out-Null
					        $selection.MoveDown() | Out-Null
							$doc.ActiveWindow.ActivePane.view.SeekView = 0
							$selection.EndKey(6, 0) | Out-Null
							$selection.TypeParagraph()
							break
						}
						"simpletable" {
							Write-Verbose "writing table type: simpletable"
                            $Table = $Null
					        $TableRange = $Null
					        $TableRange = $doc.Application.Selection.Range
                            $Columns = 0
                            foreach ($field in $HealthCheck.Fields.Field) {
                                if ($section -eq 5) {
                                    if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
                                    elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
                                }
                                $Columns++
                            }

							$Table = $doc.Tables.Add($TableRange, $Columns, 2)
							$table.Style = $TableSimpleStyle
							$i = 1;
							Write-Log -message ("Table: $Columns rows and 2 columns") -logfile $logfile
							$records = 1
							$y=0
		                    foreach ($field in $HealthCheck.Fields.Field) {
                                if ($section -eq 5) {
                                    if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
                                    elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
                                }

								if ($records -ge 500) {
									Write-Log -message ("Exported $(500*($y+1)) records") -logfile $logfile
									$records = 1
									$y++
								}
								$Table.Cell($i, 1).Range.Font.Bold = $true
								$Table.Cell($i, 1).Range.Text = $field.Description
								$Table.Cell($i, 2).Range.Font.Bold = $false

								if ($poshversion -ne 3) { 
									$TextToWord = "";
									switch ($field.Format.ToLower()) {
										"message" {
											$TextToWord = Get-MessageInformation -MessageID ($datatable.Rows[0].$($field.FieldName))
											break ;
										}
										"messagesolution" {
											$TextToWord = Get-MessageSolution -MessageID ($datatable.Rows[0].$($field.FieldName))
											break ;
										}											
										default {
											$TextToWord = $datatable.Rows[0].$($field.FieldName)
											break;
										}
									}
                                    if ([string]::IsNullOrEmpty($TextToWord)) { $TextToWord = " " }
									$Table.Cell($i, 2).Range.Text = $TextToWord.ToString()
								}
								else {
									$TextToWord = "";
									switch ($field.Format.ToLower()) {
										"message" {
											$TextToWord = Get-MessageInformation -MessageID ($datatable.$($field.FieldName))
											break ;
										}
										"messagesolution" {
											$TextToWord = Get-MessageSolution -MessageID ($datatable.$($field.FieldName))
											break ;
										}											
										default {
											$TextToWord = $datatable.$($field.FieldName) 
											break;
										}
									}
                                    if ([string]::IsNullOrEmpty($TextToWord)) { $TextToWord = " " }
									$Table.Cell($i, 2).Range.Text = $TextToWord.ToString()
								}
								$i++
								$records++
							}

					        $selection.EndOf(15) | Out-Null
					        $selection.MoveDown() | Out-Null
							$doc.ActiveWindow.ActivePane.view.SeekView = 0
							$selection.EndKey(6, 0) | Out-Null
							$selection.TypeParagraph()
							break
							break
						}
						default {
                            Write-Verbose "writing table type: default"
							$records = 1
							$y=0
		                    foreach ($row in $datatable) {
								if ($records -ge 500) {
									Write-Log -message ("Exported $(500*($y+1)) records") -logfile $logfile
									$records = 1
									$y++
								}
		                        foreach ($field in $HealthCheck.Fields.Field) {
									$TextToWord = "";
									switch ($field.Format.ToLower()) {
										"message" {
											$TextToWord = ($field.Description + " : " + (Get-MessageInformation -MessageID ($row.$($field.FieldName))))
											break ;
										}
										"messagesolution" {
											$TextToWord = ($field.Description + " : " + (Get-MessageSolution -MessageID ($row.$($field.FieldName))))
											break ;
										}												
										default {
											$TextToWord = ($field.Description + " : " + $row.$($field.FieldName))
											break;
										}
									}
                                    if ([string]::IsNullOrEmpty($TextToWord)) { $TextToWord = " " }
									Write-WordText -wordselection $selection -text ($TextToWord.ToString()) -newline $true
		                        }
								$selection.TypeParagraph()
								$records++
		                    }
						}
                	}
				}
			}
		}
        if ($bFound -eq $false) {
		    Write-WordText -wordselection $selection -text $healthCheck.EmptyText -newline $true
		    Write-Log -message ("Table does not exist") -logfile $logfile -severity 2
		    $selection.TypeParagraph()
		}
	}
}

#endregion

try {
	$poshversion = $PSVersionTable.PSVersion.Major
	if (!(Test-Path -Path ($currentFolder + $healthcheckfilename))) {
        Write-Host "File $($currentFolder)$($healthcheckfilename) does not exist, no futher action taken" -ForegroundColor Red
		Exit
    }
    else { 
        [xml]$HealthCheckXML = Get-Content ($currentFolder + $healthcheckfilename) 
    }

	if (!(Test-Path -Path ($currentFolder + "Messages.xml"))) {
        Write-Host "File $($currentFolder)Messages.xml does not exist, no futher action taken" -ForegroundColor Red
		Exit
    }
    else { 
        [xml]$MessagesXML = Get-Content ($currentFolder + 'Messages.xml') 
    }

    if (Test-Folder -Path $logFolder) {
    	try {
        	New-Item ($logFolder + 'Test.log') -type file -force | out-null 
        	Remove-Item ($logFolder + 'Test.log') -force | out-null 
    	}
    	catch {
        	Write-Host "Unable to read/write file on $logFolder folder, no futher action taken" -ForegroundColor Red
        	Exit    
    	}
	}
	else {
        Write-Host "Unable to create Log Folder, no futher action taken" -ForegroundColor Red
        Exit
	}
	$bLogValidation = $true

	if (Test-Folder -Path $reportFolder -Create $false) {
		if (!(Test-Path -Path ($reportFolder + "config.xml"))) {
        	Write-Log -message "File $($reportFolder)config.xml does not exist, no futher action taken" -severity 3 -logfile $logfile
        	Exit
		}
		else { 
            $ConfigTable = Import-Clixml -Path ($reportFolder + "config.xml") 
        }
		
		if ($poshversion -ne 3) { $NumberOfDays = $ConfigTable.Rows[0].NumberOfDays }
		else { $NumberOfDays = $ConfigTable.NumberOfDays }
		
		
		if (!(Test-Path -Path ($reportFolder + "report.xml"))) {
        	Write-Log -message "File $($reportFolder)report.xml does not exist, no futher action taken" -severity 3 -logfile $logfile
        	Exit
		}
		else {
	 		$ReportTable = New-Object System.Data.DataTable 'ReportTable'
	        $ReportTable = Import-Clixml -Path ($reportFolder + "report.xml")
		}
	}
	else {
        Write-Host "$reportFolder does not exist, no futher action taken" -ForegroundColor Red
        Exit
	}
	
    if (!(Test-Powershell -version 3)) {
        Write-Log -message "Powershell version ($poshversion) not supported. Minimum version should be 3, no futher action taken" -severity 3 -logfile $logfile
        Exit
    }
    
    if (!(Test-Powershell64bit)) {
        Write-Log -message "Powershell is not 64bit, no futher action taken" -severity 3 -logfile $logfile
        Exit
    }

	Write-Log -message "==========" -logfile $logfile -showmsg $false
    Write-Log -message "Starting HealthCheck report" -logfile $logfile
    Write-Log -message "Running Powershell version $poshversion" -logfile $logfile
    Write-Log -message "Running Powershell 64 bits" -logfile $logfile
    Write-Log -message "Report Folder: $reportFolder" -logfile $logfile
    Write-Log -message "Detailed Report: $detailed" -logfile $logfile
	Write-Log -message "Number Of days: $NumberOfDays" -logfile $logfile

	try {
        $Word = New-Object -ComObject "Word.Application" -ErrorAction Stop
    }
    catch {
        Write-Host "Error: This script requires Microsoft Word" -ForegroundColor Red
        break
    }
    $wordVersion = $Word.Version
	Write-Log -message "Word Version: $WordVersion" -logfile $logfile	
	Write-Verbose "Microsoft Word version: $WordVersion"
	if ($WordVersion -eq "16.0") {
		$TableStyle = "Grid Table 4 - Accent 1"
		$TableSimpleStyle = "List Table 1 Light - Accent 1"
	}
	elseif ($WordVersion -eq "15.0") {
		$TableStyle = "Grid Table 4 - Accent 1"
		$TableSimpleStyle = "List Table 1 Light - Accent 1"
	}
	elseif ($WordVersion -eq "14.0") {
		$TableStyle = "Medium Shading 1 - Accent 1"
		$TableSimpleStyle = "Light Grid - Accent 1"
	}
	else { 
		Write-Log -message "This script requires Word 2010 to 2016 version, no further action taken" -severity 3 -logfile $logfile 
		Exit
	}

    Write-Verbose "opening MS Word"
    $Word.Visible = $True
	$Doc = $Word.Documents.Add()
	$Selection = $Word.Selection
	
    Write-Verbose "disabling real-time spelling and grammar check"
	$Word.Options.CheckGrammarAsYouType  = $False
	$Word.Options.CheckSpellingAsYouType = $False
	
    Write-Verbose "loading default building blocks template"
	$word.Templates.LoadBuildingBlocks() | Out-Null	
	$BuildingBlocks = $word.Templates | Where {$_.name -eq "Built-In Building Blocks.dotx"}
	$part = $BuildingBlocks.BuildingBlockEntries.Item($CoverPage)
	
    if ($doc -eq $null) {
        Write-Error "Failed to obtain handle to Word document"
        break
    }
    if ($bAutoProps -eq $True) {
        Write-Verbose "setting document properties"
        $doc.BuiltInDocumentProperties("Title")    = "System Center Configuration Manager HealthCheck"
        $doc.BuiltInDocumentProperties("Subject")  = "Prepared for $CustomerName"
	    $doc.BuiltInDocumentProperties("Author")   = $AuthorName
	    $doc.BuiltInDocumentProperties("Company")  = $CopyrightName
        $doc.BuiltInDocumentProperties("Category") = "HEALTHCHECK"
        $doc.BuiltInDocumentProperties("Keywords") = "sccm,healthcheck,systemcenter,configmgr,$CustomerName"
	}

    Write-Verbose "inserting document parts"

	$part.Insert($selection.Range,$True) | Out-Null

	$selection.InsertNewPage()
	
	Write-Verbose "inserting table of contents"
    $toc=$BuildingBlocks.BuildingBlockEntries.Item("Automatic Table 2")
	$toc.insert($selection.Range,$True) | Out-Null

	$selection.InsertNewPage()

	$currentview = $doc.ActiveWindow.ActivePane.view.SeekView
	$doc.ActiveWindow.ActivePane.view.SeekView = 4
	$selection.HeaderFooter.Range.Text= "Copyright $([char]0x00A9) $((Get-Date).Year) - $CopyrightName"
	$selection.HeaderFooter.PageNumbers.Add(2) | Out-Null
	$doc.ActiveWindow.ActivePane.view.SeekView = $currentview
	$selection.EndKey(6,0) | Out-Null

    $absText = "This document provides a point-in-time inventory and analysis of the "
    $absText += "System Center Configuration Manager site for $CustomerName"
	
	Write-WordText -wordselection $selection -text "Abstract" -style "Heading 1" -newline $true
	Write-WordText -wordselection $selection -text $absText -newline $true

	$selection.InsertNewPage()

    ReportSection -HealthCheckXML $HealthCheckXML -section '1' -doc $doc -selection $selection -logfile $logfile 
    ReportSection -HealthCheckXML $HealthCheckXML -section '2' -doc $doc -selection $selection -logfile $logfile 
    ReportSection -HealthCheckXML $HealthCheckXML -section '3' -doc $doc -selection $selection -logfile $logfile 
    ReportSection -HealthCheckXML $HealthCheckXML -section '4' -doc $doc -selection $selection -logfile $logfile 
    ReportSection -HealthCheckXML $HealthCheckXML -section '5' -doc $doc -selection $selection -logfile $logfile 
    if ($detailed -eq $true) {
        ReportSection -HealthCheckXML $HealthCheckXML -section '5' -detailed $true -doc $doc -selection $selection -logfile $logfile 
    }
    ReportSection -HealthCheckXML $HealthCheckXML -section '6' -doc $doc -selection $selection -logfile $logfile 
}
catch {
	Write-Log -message "Something bad happen that I don't know about" -severity 3 -logfile $logfile
	Write-Log -message "The following error happen, no futher action taken" -severity 3 -logfile $logfile
    $errorMessage = $Error[0].Exception.Message
    $errorCode = "0x{0:X}" -f $Error[0].Exception.ErrorCode
    Write-Log -message "Error $errorCode : $errorMessage" -logfile $logfile -severity 3
    Write-Log -message "Full Error Message Error $($error[0].ToString())" -logfile $logfile -severity 3
	$Error.Clear()
}
finally {
	if ($toc -ne $null) { $doc.TablesOfContents.item(1).Update() }
	if ($bLogValidation -eq $false) {
		Write-Host "Ending HealthCheck Export"
        Write-Host "==========" 
	}
	else {
        Write-Log -message "Ending HealthCheck Export" -logfile $logfile
        Write-Log -message "==========" -logfile $logfile
	}
}