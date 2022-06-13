# Archive files

----
## Archive-Files
PowerShell script for batching and archiving files. 
Files older than a given time period are batched ether weekly or monthly and added to archives.

The script was created to support running against folder that might have millions of files. 
Some systems can produce many individual transactions logs in a single day. Leaving them in the output folder can cause delays as even listing the files can be come slow. If the files cant be deleted for audit purposes archiving them might be an appropriate solution.
The script runs in two passes, 
- Iterate through all files and group them by the desired time period (week or month).
  - It is faster to Iterate and group them then to have PowerShell to sort the files by date.
  - PowerShell `Get-ChildItems` is used as this appears to be the most performant method of listing the files while having access to the created date.
- Archive each group of files.
  - Ensures each archive is only opened and closed. 

[Archive Performance discussed here](https://docs.ostat.com/docs/powershell/Archive_Files.html)

----
## New-RandomFiles

Supporting script for creating sample files. This allows for testing of the above Archive script.
Files are given a GUID as a name, and the content is also GUID based which should give consistent compression.
Created files have the file timestamps modified to disperse the files randomly across a given time period.