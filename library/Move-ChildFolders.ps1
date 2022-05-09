#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.2.0.5'
<#
Comments
    Moves all the items in the source folder to the destination folder
	Both folder must exist

Change History
version 0.3.0.1
    added age filter
version 0.2.0.0
    Added comments 
version 0.1.0.0
    First version
#>

function Move-ChildFolders {
 param([string]$source, 
 	   [string]$destination, 
	   [datetime]$ageFilter = [datetime]::MaxValue
 	   )
<#
    .Synopsis
        Moves all the items in the source folde to the destination folder
        only folders are moved.
    .Example
        Move-ChildFolders C:\temp\source c:\temp\dest
        moves C:\temp\source\*.*  to c:\temp\dest
    .Parameter source
    .Parameter destination
	.Parameter ageFilter
		Only folder older than the passed in date will be copied. Default is to copy all folder
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Move-ChildFolders
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [Source $source, destination $destination, ageFilter $ageFilter]")
    
    
    if ([System.String]::IsNullOrEmpty($source) -or (Test-Path $Source -IsValid) -eq $false)
    {
        Write-error ("Source is not valid : '$source'")
        return
    }
    
    if ([System.String]::IsNullOrEmpty($destination) -or (Test-Path $destination -IsValid) -eq $false)
    {
        Write-error ("Destination is not valid : '$destination'")
        return
    }
    
    #refrence to source folder
    $SourceFolder = get-item -LiteralPath $source 
    if ($SourceFolder -eq $null)
    {
        Write-error ("Source folder does not exist`n$source")
        return
    }
      
    # Create destination folder
    # CreateDirectoryIfNeeded($destination)
    if ((test-path -LiteralPath $destination) -ne $True)
    {
        Write-error ("Destination folder does not exist`$destination")
        return
    }
     
    #loop all folder in the source folder
    foreach ($ChildFolder in (get-Childitem -LiteralPath $SourceFolder | where {$_.PSIsContainer}))
    {
		#$target = join-path -path $Destination -childpath $ChildItem.Name
 
        #Check if its a folder
        if ($ageFilter -eq [datetime]::MaxValue -or $ChildFolder.Lastwritetime -lt $ageFilter)
        {
            #$logPath = [System.IO.Path]::GetTempFileName()
            $logPath = Create-TempLogFile "Move-ChildFolders"

            Start-Transcript $logPath
     
            $result = CopyRemove-Folder $ChildFolder.FullName $destination  -verbose 
        
            Stop-Transcript
            
            $newFolder = get-item -LiteralPath $result  
            $logFolder = join-path -path $newFolder.Fullname -childpath "Log"
            
            Save-Logfile $logPath $logFolder "CopyRemove-Folder"
        }
    }
    
    Log_Message("End $($MyInvocation.MyCommand.Name)")
}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURHvw/gWhz3hGx5fAFAjhbRYr
# b6OgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xMjEwMTEwOTIxNDlaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAtgqmw2j4wUCE
# 7CY2tvUzT/zybRnFTBYcfD6G0jqAxTDVF8IBLudQ8JT050N9k/t5J+LIPWB42yr9
# kEWjW+14Kf71FKHXkGOMo97h+daSMuMQmkhLDsf89Oo6rSJiTL4vBMCn4aRfPK6Z
# SLmipNqx2GXdSENRHBwNL/xDUl2bR70CAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQhO+BACS94IWK23FVrvD18aEuMCwxKjAoBgNVBAMT
# IVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQv2FEF1g6paRFCcYM
# 8UlkRTAJBgUrDgMCHQUAA4GBAJTyBSZO/nFGEge79osRWILjKxXA3zyT5ooxlO0G
# 5e/a47iWaDdffcotXLUU0XyF765LmO4FKnmdkLRX5YX/rqdyuxK3CLgT1rDzyq9D
# uO2FvBPUCFzSX4mbVcc6yfdC/S5eZ8NaOHb4mixtzGFLWPxMcpao5augzbPqHKEE
# NhViMYIBYDCCAVwCAQEwQDAsMSowKAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENl
# cnRpZmljYXRlIFJvb3QCELwX/PhWdU6WRkGeALQV3DEwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FDt23eU6Qk2r2NcfXe1hmLa2TW5ZMA0GCSqGSIb3DQEBAQUABIGALjhbd96/kBE8
# eyXg/f7Mt4FkdHsLisPbsbhyODo2vtgK7KLffZU3VeAFZVk/A7km2TMlXnsfj9UX
# SJOr8vMfxN3k+trIRlHOCdiibUiaxMbbRuAG/bF7u7Wbb7g/acG9RbKgz/NK3Q2v
# aVshVyJlND5zM5xWQKZCZWVReqlgjAo=
# SIG # End signature block
