#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.2.0.4'

function Collapse-Folder([string]$FolderPath) 
{
<#
    .Synopsis
        moves the contence of a folder in to its parent and removes the folder
    .Description
    .Example
        Collapse-Folder C:\foo\bar\
        The contence of bar will be moved in to foo, and folder bar deleted.
    .Parameter Folder
       The folder to process
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Collapse-Folder
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:this could alse be called demote (to fit with promote)
    .Link
        Http://www.ostat.com

#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")
        
    if ([string]::IsNullOrEmpty($FolderPath)) {
        write-error "input value is null. Exiting" 
        break
    }
    
    if ((test-path -LiteralPath $FolderPath -pathtype container) -eq $False) {
        write-error "folder path is invalid : $Folder. Exiting"
        break
    }
              
    #refrence to source folder, and parent folder
    $sourceFolder = get-item -LiteralPath $FolderPath   
    if ($sourceFolder -eq $Null) {
        write-error "cound not get refrence to source folder. Exiting"
        break
    }
    
    $parentFolder = get-item -LiteralPath $sourceFolder.Parent.FullName
    if ($parentFolder -eq $Null) {
        write-error "cound not get refrence to parent folder. Exiting"
        break
    }
    

    #loop all items in the folder that is to be processed
    foreach ($actionItem in get-Childitem -LiteralPath $sourceFolder) 
    {
        Log_Message "moving item to parent folder: $($actionItem.FullName)"
        
        CopyRemove-FileSystemItem $actionItem.FullName $parentFolder.FullName
        
    }
    
    #confirm folder is empty
    if ($sourceFolder.GetDirectories().count -gt 0 -or $sourceFolder.GetFiles().count -gt 0 ) 
    {
        write-error "Source still not not empty. Exiting" 
        Break
    } 
    else 
    {
        write-verbose "removing source folder"
    
        remove-Item -LiteralPath $sourceFolder.FullName ?Force
    }
    
    Log_Message("End - $($MyInvocation.MyCommand.Name)")
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1AQyWirnGB8hSsQwaS6w1j/G
# L1OgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FPmBOo4El3k8/DSpZMLvg/5lRVe2MA0GCSqGSIb3DQEBAQUABIGAjKbVQXnOQu90
# 7qPT0ROXsCHRoF/yceUBw2ZP3r/td+26sBvUPtzCvYX/OA5HHTaFvkuEaktR0JWC
# RhqbDa8QGV3lyXou8/4q8LvOg4nwDcVd9ibZ3TNaFzbdJ+6NuVMhnDE0OlrOoMb2
# kBGeE/ik7VcXRheJq/6RK9qRYveI5GY=
# SIG # End signature block
