#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.3.0.5'
<#
Comments
    copys an item (the source) to a new destination, then deletes the source if copy was successful
#>

function CopyRemove-FileSystemItem([string]$Source, [string]$Target) 
{
<#
    .Synopsis
        Moves an item from one location to another. If move-item fails performs copy and delete.
    .Description
        Move-item is the same as rename, and only works when source and destination are the same drive.
		
		Function will attempt to use Move-Item, if this fails it will perform a copy and remove.
        
    .Example
        CopyRemove-FileSystemItem  c:\temp\testMove c:\temp\testMoveDest -verbose
        moves testMove to c:\temp\testMoveDest\testMove
    .Parameter Source
        Source folder to be moved
    .Parameter Target
        Targettarget location (will become source folders parent)
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS Destination
        destination path
    .Notes
        NAME: CopyRemove-FileSystemItem
        AUTHOR: max
        LASTEDIT: 12/31/2010 16:00:59
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version [Source $Source, Target $Target]")

    if ([string]::IsNullOrEmpty($Source) -eq $true -or (test-path -LiteralPath $Source) -ne $True)
    {
        Write-Error("Source does not exist or is blank : '$source'")
        return
    }  
    
    #Create Target folder if needed
    if ([string]::IsNullOrEmpty($Target) -eq $true)
    {
        Write-Error("Target is blank : '$Target'")
        return
    }  
    
    CreateDirectoryIfNeeded($Target)
    if ([string]::IsNullOrEmpty($Target) -eq $true -or (test-path -LiteralPath $Target) -ne $True)
    {
        Write-Error("Target Could not be created : '$Target'")
        return
    }
    
    $SourceItem = get-item -LiteralPath $Source -Force
    
    #Check what type of item it is 
    if ($SourceItem.GetType().Name -eq 'DirectoryInfo')
    {
        Write-verbose ("item is a folder")
        
        #New folder for moved item 
        $Destination = join-path -path $Target -childpath $SourceItem.Name
          
        #Create new folder if needed
        Write-Host("Destination folder : '$Destination'")
        CreateDirectoryIfNeeded($Destination)
        if ((test-path -LiteralPath $Destination) -ne $True)
        {
            Write-error ("unable to create Destination folder : '$Destination'")
            return
        }
        
        #loop all items in the folder
        foreach ($ChildItem in get-Childitem -LiteralPath $SourceItem -Force)
        {
            Write-verbose ("Processing item: " +  $ChildItem.FullName)
            
            #move child item
            CopyRemove-FileSystemItem $ChildItem.FullName $Destination | out-null
       
            Write-verbose ("Item complete : " +  $ChildItem.FullName)
        }
            
        #Remove what should be an empty folder    
        #if target folder exists and source folder is empty, remove source
        if ((test-path -LiteralPath $SourceItem.FullName) -eq $True)
        {
            Write-verbose ("Found target folder. Number of children remaining in source (expected 0) : '$($SourceItem.GetFiles().Count)'")
            
            if ($SourceItem.GetFiles().Count -eq 0)
            {
                write-verbose ("removing '$($SourceItem.FullName)'")
                remove-item -LiteralPath $SourceItem.FullName -Force | out-null
            }
            else
            {
                Write-error ("Source is not empty, skipping source removal")
           }
        }
        else
        {
            Write-verbose ("Expected target folder does not exist, skipping source removal")
        }
    }     
    else
    {
        Write-verbose("copying file : " + $SourceItem.FullName)

        #expected new file name
        $targetName = join-path -path $Target -childpath $SourceItem.Name
                
        #try moving the item (move is really rename) and is the fastest method
        move-item -LiteralPath $SourceItem.FullName -destination $Target -Force 
        
        #confirm that the file moved successfully
        if ((test-path -LiteralPath $targetName) -eq $False -or (test-path -LiteralPath $SourceItem.FullName) -eq $True )
        {
            #if the move failed copy and remove the copy file to new location        
            copy-item -LiteralPath $SourceItem.FullName -destination $Target -Force 
            
            #confirm that the file copied successfully
            if ((test-path -LiteralPath $targetName) -ne $True)
            {
                Write-Error ("Target file does not exist, skipping source file removal")
            }
            else
            {
                #TODO : check size, hash, date
                
                #del old file
                Write-verbose ("removing " + $SourceItem.FullName)
                remove-item -LiteralPath $SourceItem.FullName -Force | out-null
            }
        }
    }  
    
    Write-verbose ("Task - Move completed, new name '$Destination'")
    
    return $Destination 
}


function CopyRemove-Folder([string]$Source, [string]$Target) 
{
<#
    .Synopsis
        copies a folder to a new location and removes original
        not really needed, could call CopyRemove-FileSystemItem directly (supports legacy scripts)
        
    .Example
        CopyRemove-Folder  c:\temp\testMove c:\temp\testMoveDest -verbose
        moves testMove to c:\temp\testMoveDest\testMove
    .Parameter Source
        Source folder to be moved
    .Parameter Target
        Targettarget location (will become source folders parent)
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: CopyRemove-Folder
        AUTHOR: max
        LASTEDIT: 12/31/2010 16:00:59
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version [Source $Source, Target $Target]")

    if ([string]::IsNullOrEmpty($Source) -eq $true -or (test-path -LiteralPath $Source) -ne $True)
    {
        Write-Error("Source does not exist : '$Source'")
        return
    }  
    
    $SourceItem = get-item -LiteralPath $Source 

    #Check what type of item it is 
    if ($SourceItem.GetType().Name -eq 'DirectoryInfo')
    {
        Write-verbose ("Confirmed source is a folder")
        CopyRemove-FileSystemItem $SourceItem.FullName $Target | out-null
    }     
    else
    {
         Write-Error("Source is not a folder, Ending")
         return
    }  
    
}

function CopyRemove-ChildFolders([string]$Source, [string]$Destination) 
{
<#
    .Synopsis
        Copies all the folders in the source to the destination
        
    .Example
       CopyRemove-ChildFolders  c:\temp\testMove c:\temp\testMoveDest -verbose
       all folders in testMove will be moved to to c:\temp\testMoveDest\
    .Parameter Source
        Source folder to be moved
    .Parameter Target
        Targettarget location (will become source folders parent)
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: CopyRemove-Folder
        AUTHOR: max
        LASTEDIT: 12/31/2010 16:00:59
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version [Source $Source, Target $Destination]")
  
    Write-Host("Task - Moving folder :  '$Source'")
    if ([string]::IsNullOrEmpty($Source) -eq $true -or (test-path -LiteralPath $Source) -ne $True)
    {
        Write-Error("Source does not exist or is blank : '$Source'")
        return
    }  
    
    $SourceItem = get-item -LiteralPath $Source 

    #loop all items in the folder
    foreach ($ChildItem in get-Childitem -LiteralPath $SourceItem)
    {
        #Check what type of item it is 
        if ($ChildItem.GetType().Name -eq 'DirectoryInfo')
        {
            Write-verbose ("Processing item : '$($ChildItem.FullName)'")
            
            #move contence of folder
            CopyRemove-FileSystemItem $ChildItem.FullName $Destination | out-null
       
            Write-verbose ("Item complete : '$($ChildItem.FullName)'")
        }
    }
    
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbBim+4VgLliUsq+E4dNaVYAd
# auOgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FM/5Kmn3L39UHx3XyNhuJHcNVKk0MA0GCSqGSIb3DQEBAQUABIGARj+jeqe8qSxc
# O5RxOTz4BiRM31InNKxTFKWcMHFxFvVAL/RToYabnvyZ06oz/VnQrC4IDuc+eNkv
# WP7ZlloOXwHk3qCrGT8wVgJCev6Eh/GWsBxxiQNQ/0t/9Jv/BkHtYhHLXzcO9Grx
# 8V58QP0lXAx3TajSBCKwzqB7cGMMp3s=
# SIG # End signature block
