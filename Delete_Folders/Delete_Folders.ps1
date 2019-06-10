# Create log folder if it doesn't exist
$Logpath = ".\output"
If ((Test-Path -Path $Logpath) -ne $true) { New-Item -ItemType directory -Path $Logpath}
#
# Create log file
$Logfile = ".\output\Delete_Folders"+ (get-date -format '_ddMMMyyyy_hhmm') +".txt"
Write "================================================================" |Add-Content $Logfile
Write "Delete Folders Output File" |Add-Content $Logfile
Write "================================================================" | Add-Content $Logfile
#
#Get the csv list of Folders
$folders = Read-Host "CSV file (with column header 'Folder')" 
Write "Importing csv: $folders" |Add-Content $Logfile

import-csv $folders | foreach-object{
$folder = $_.Folder
Write "Removing $folder" |Add-Content $Logfile
    try {
        Remove-Item -Path $folder -Verbose 4>&1 -Recurse -Confirm:$false -ErrorAction Stop|Add-Content $LogFile
    } catch {
        Add-Content $LogFile "`nError deleting folder: $folder"
    }
#Remove-Item -Path $folder -Verbose 4>&1 -Recurse -Confirm:$false | Add-Content $Logfile
}
Write-Host "Path to logfile $Logfile"
