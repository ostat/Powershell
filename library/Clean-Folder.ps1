#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.3.0.5'
<#
Comments 
	A 'list' folder is a folder with many unrelated items in it. Should only contain folders.
	An 'item' folder is a folder with a single item int it. It could contain many files but all are related.
	See function descriptions for specifics.
#>

function Clean-Item-Folder([string]$FolderPath) 
{
<#
    .Synopsis
        Cleans a folder, the script assumes that the folder is an item folder not a list folder.
    .Description
        step 1, unrar all files
        step 2, demote any cd1, cd2 ,cd3 folders
        step 3, demote folders that is the only item in a folder (not implemented)
        
    .Example Clean-Item-Folder
        Clean-Item-Folder c:\foo\
        Cleans the folder foo assuming it is an item folder.
        
    .Parameter Folder
        Folder to be processed
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None
    .Notes
        NAME: Clean-Item-Folder
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:46:02
        KEYWORDS:
    .Link
        Http://www.ostat.com
#Requires -Version 2.0
#>
    #this could alse be called demote (to fit with promote)
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")
        
    if ([string]::IsNullOrEmpty($FolderPath)) {
        write-error "input value is null. Exiting" 
        break
    }

    #refrence to folder to be processed
    #Should be a container folder
    $FolderToClean = get-item -LiteralPath $FolderPath   
    if ($FolderToClean -eq $Null) {
        write-error "cound not get folder. Exiting"
        break
    }
    
    #step 1, unrar all files
    Extract-RARs-in-Folder $FolderToClean.FullName
    
    #loop all items in the folder that is to be processed
    #this loop should not recurse, should only return folders that match
    foreach ($SoureItem in get-Childitem -LiteralPath $FolderToClean)
    {
        #check if it is a folder item
        if ($SoureItem.GetType().Name -eq 'DirectoryInfo')
        {
            #Step 2, Collapse folders called cd1, cd2, cd3
            if($SoureItem.Name -eq "CD1" -or $SoureItem.Name -eq "CD2" -or $SoureItem.Name -eq "CD3")
            {
                $logFolder = join-path -path $FolderToClean.FullName -childpath "Log"
                $logPath = Create-TempLogFile "Collapse-Folder"
                
                Start-Transcript $logPath
         
                Collapse-Folder([string]$SoureItem.FullName) 
            
                Stop-Transcript
            }           
        }           
    }    

    Log_Message("End $($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")    
}


function Clean-List-Folder([string]$FolderPath) 
{
<#
    .Synopsis
        Cleans a folder, assumes that the folder is a list folder not an item folder.
    .Description
        Step 1: promte items, list should not contain items not with in a folder. 
        step 2: clean all child folders as item folders
    .Example Clean-Item-Folder
        Clean-Item-Folder c:\foo\
        Cleans the folder foo assuming it is an item folder.
        
    .Parameter Folder
        Folder to be processed
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None
    .Notes
        NAME: Clean-List-Folder
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:46:02
        KEYWORDS:
        FurureDev:Determin if child folder is a list or an item.
    .Link
        Http://www.ostat.com
#Requires -Version 2.0
#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")
        
        
    if ([string]::IsNullOrEmpty($FolderPath)) {
        write-error "input value is null. Exiting" 
        break
    }
    
    #refrence to folder to be processed
    #Should be a container folder
    $FolderToClean = get-item -LiteralPath $FolderPath   
    if ($FolderToClean -eq $Null) {
        write-error "cound not get folder. Exiting"
        break
    }
    
    #Step 1: promote files in folder
    Promote-Files $FolderToClean.FullName -debug
    
    #step 2: loop all folders, determnin type and process
    #this loop should not recurse, should loop all folders
    foreach ($SoureItem in get-Childitem -LiteralPath $FolderToClean)
    {
        if ($SoureItem.GetType().Name -eq 'DirectoryInfo')
        {
            #TODO add check for folder type.
            #read folder.xml, 
            
            #if no folder.xml then use logic (how simialr file names are)
            #if assume list, files will promote
            #if assume item, children will demote.
                        
            Clean-Item-Folder $SoureItem.FullName  
        }
    }  
    
    Log_Message("End $($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")
}


# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDAqQ8VpmJvU55lysAUegI0rI
# jF+gggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FOKhX/91QxA3hmkND41Y0YtnS3a/MA0GCSqGSIb3DQEBAQUABIGARD3ss0LN5B0A
# v1ehmnMJQSe2qt5OTHfK6TL3MRmwdY5u4nYKUH347f5qB1NouYv0kv26pVVtocGc
# NiBw8lpvzIZ1Bv2leH4YywG0BZAy8J1fP7Y7qdNKzdWShDhxWQeHBenHIIhZ0YfO
# rg73Y4cuFzOkQGUlobcAzGjqxmsutp4=
# SIG # End signature block
