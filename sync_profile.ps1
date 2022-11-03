$doc_dir = [environment]::getfolderpath("mydocuments")
$ps_5 = "$doc_dir\windowspowershell\microsoft.powershell_profile.ps1"
$ps_7 = "$doc_dir\powershell\microsoft.powershell_profile.ps1"

$ps_5_time = (get-childitem $ps_5).lastwritetime
$ps_7_time = (get-childitem $ps_7).lastwritetime

write-host ""
write-host "------ Powershell Profile Sync ------"
if ($ps_5_time -gt $ps_7_time) {
	write-host "Powershell Profile 5 is newer the 7"
	write-host "Version 5: $ps_5_time"
	write-host "Version 7: $ps_7_time"
	write-host "Copy: $ps_5"
	write-host "To: $ps_7"
	cp $ps_5 $ps_7	
	write-host "Copy done"
} elseif ($ps_5_time -lt $ps_7_time) {
	write-host "Powershell Profile 7 is newer the 5"
	write-host "Version 5: $ps_5_time"
	write-host "Version 7: $ps_7_time"
	write-host "Copy: $ps_7"
	write-host "To: $ps_5"
	cp $ps_7 $ps_5
	write-host "Copy done"
} else {
	write-host "Powershell Profile 5 and 7 have the same timestamp"
	write-host "Version 5: $ps_5_time"
	write-host "Version 7: $ps_7_time"
	write-host "No action needed"
}
write-host "-------------------------------------"
write-host ""
