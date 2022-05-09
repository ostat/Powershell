#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.3.1.7'
<#
Comments
    unrars a rar file or set of rar files, then if "all ok" removes the rar files
#>


#########################################################
#Load config from file
#########################################################
[xml]$configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}

#path to unrar.exe I.E. c:\bin\unrar\unrar.exe
$Script:unrarName =  $configFile.Configuration.UnRarExePath 
	
function Extract-RAR-File([string]$FilePath, [bool]$RemoveSuccessfull = $false) 
{
<#
    .Synopsis
        unrars a file or set of rar files, then if "all ok" removes the rar files
    .Description
    .Example
        Extract-RAR-File c:\temp\foo.rar
        Extracts contence of foo.rar to folder temp.
    .Parameter FilePath
        path to rar file 
    .Parameter RemoveSuccessfull
        remove rar files if successfull
    .INPUTS
        None. You cannot pipe objects to Extract-RAR-File.
    .OUTPUTS
        System.String.
    .Notes
        NAME: Extract-RAR-File
        AUTHOR: max
        LASTEDIT: 2011-01-01 08:11:03
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version : [FilePath $FilePath, RemoveSuccessfull $RemoveSuccessfull]")
    
    # Verify we can access UNRAR.EXE .
	if ([string]::IsNullOrEmpty($unrarName) -or (Test-Path -LiteralPath $unrarName) -ne $true)
	{
	    Write-Error "Unrar.exe path does not exist '$unrarPath'."
        return
    }
	
    [string]$unrarPath = $(Get-Command $unrarName).Definition
    if ( $unrarPath.Length -eq 0 )
    {
        Write-Error "Unable to access unrar.exe at location '$unrarPath'."
        return
    }

   # Verify we can access to the compressed file.
	if ([string]::IsNullOrEmpty($FilePath) -or (Test-Path -LiteralPath $FilePath) -ne $true)
	{
	    Write-Error "Compressed file does not exist '$FilePath'."
        return
    }
	
    [System.IO.FileInfo]$Compressedfile = get-item -LiteralPath $FilePath 
    
    #set Destination to basepath folder
    #$fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($Compressedfile.Name)
    #$DestinationFolder = join-path -path $Compressedfile.DirectoryName -childpath $fileBaseName
    
    #set Destination to parent folder
    $DestinationFolder = $Compressedfile.DirectoryName 

    # If the extract directory does not exist, create it.
    CreateDirectoryIfNeeded ( $DestinationFolder ) | out-null

    Write-Output "Extracting files into $DestinationFolder"
    &$unrarPath x -y  $FilePath $DestinationFolder | tee-object -variable unrarOutput 
    
    #display the output of the rar process as verbose
    $unrarOutput | ForEach-Object {Write-Verbose $_ }
     
    if ( $LASTEXITCODE -ne 0 )
    { 
        # There was a problem extracting. 
        #Get-Content $unrarOutput 
        #Display errror
        Write-Error "Error extracting the .RAR file" 
    }
    else
    {
        # check $SevenZipOutput to remove files
        #"^All OK$"
        Write-Verbose "Checking output for OK tag"  
        if ($unrarOutput -match "^All OK$" -ne $null) {
            if ($RemoveSuccessfull) {
                Write-Verbose "Removing files"  
                
                #remove rar files listed in output.
                $unrarOutput -match "(?<=Extracting\sfrom\s)(?<rarfile>.*)$" | 
                ForEach-Object {$_ -replace 'Extracting from ', ''} | 
                foreach-object { get-item -LiteralPath $_ } | 
                remove-item
                
            } else {
                Write-Verbose "Moving files to trash folder`n$trashPath"  
        
                [string]$trashPath = join-path -path $DestinationFolder "Trash"
                
                #create trash folder to move rars to
                CreateDirectoryIfNeeded ($trashPath)
                
                #move rar files listed in output.
                $unrarOutput -match "(?<=Extracting\sfrom\s)(?<rarfile>.*)$" | 
                ForEach-Object {$_ -replace 'Extracting from ', ''} | 
                foreach-object { get-item -LiteralPath $_ } | 
                move-item -destination $trashPath
            }
        }
    }
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsIHdHpCcV4CIDeo+z6BJ3Mlb
# GyqgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FGklUNYzCo5EKLqrvZXPTGcRUW7vMA0GCSqGSIb3DQEBAQUABIGAkk2sIfByprwt
# GFCmV8Cpys6UMpzQZ3vcaZ3wyt5OZiqNUueR3M7FgasS12nRtuW/K9qL2Q3at1U/
# kAtmGBLHdmx8bcJim+XUZCIIkerWZSSQ9pyI3yqj274WeMMJPPrcJdU/86ZH6IX2
# cCKg2558xLVfD4DyT7uDHyeI7R5PkeA=
# SIG # End signature block
