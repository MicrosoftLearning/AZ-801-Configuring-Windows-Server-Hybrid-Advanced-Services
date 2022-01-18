Get-Disk
Initialize-Disk -Number 1
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter S
Format-Volume -DriveLetter S -FileSystem NTFS

Invoke-Command -ComputerName 'SEA-SVR1.contoso.com' -ScriptBlock {
   Get-Disk
   Initialize-Disk -Number 1
   New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter S
   Format-Volume -DriveLetter S -FileSystem NTFS
}

Invoke-Command -ComputerName 'SEA-SVR1.contoso.com' -ScriptBlock {
   New-Item -Type Directory -Path '\\SEA-SVR1.contoso.com\S$\Data' -Force
   New-SmbShare -Name Data -Path 'S:\Data' -ChangeAccess 'Users' -FullAccess 'Administrators'
}

Invoke-Command -ComputerName 'SEA-SVR1.contoso.com' -ScriptBlock {
   fsutil file createnew S:\Data\report1.docx 254321098
   fsutil file createnew S:\Data\report2.docx 254321098
   fsutil file createnew S:\Data\report3.docx 254321098
   fsutil file createnew S:\Data\report4.docx 254321098
}