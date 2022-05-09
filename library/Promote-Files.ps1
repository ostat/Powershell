#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.3.0.6'
<#
Comments
    moves child files into a folder of the same name excluding the extension.
#>

#########################################################
#Load config from file
#########################################################
[xml]$configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}
	
$Script:ExclusionPattern =  $configFile.Configuration.ExclusionPattern 

function Promote-Files([string]$FolderPath) 
{
<#
    .Synopsis
        all single files in the folder will be moved in to a folder of the same name
    .Example
        Promote-Files c:\foo
        file "c:\foo\bar.txt will become c:\foo\bar\bar.txt
    .Parameter FolderPath
        container folder to be processed 
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Promote-Files
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")
      
    #refrence to folder to be processed
    #Should be a container folder
    $BasketFolder = get-item -LiteralPath $FolderPath   

    #about_Transactions
           
    #loop all items in the folder that is to be processed
    foreach ($SoureItem in get-Childitem -LiteralPath $BasketFolder)
    {
        #check if it is a file item
        if ($SoureItem.GetType().Name -eq 'FileInfo')
		{
			#does file match the exclusion list
			if(($SoureItem.Name -match $ExclusionPattern) -ne $true)
	        {
	            $logPath = Create-TempLogFile "Promote-Files"

	            Start-Transcript $logPath
	 
	            $result = Promote-File $SoureItem.FullName -verbose 
	            
	            Stop-Transcript
	            
	            if(![string]::IsNullOrEmpty($result))
	            {
	                #refrence to source folder
	                $file = get-item -LiteralPath $result  
	                $logFolder = join-path -path $file.Directory.Fullname -childpath "Log"
	            }  
	            else
	            {
	                $logFolder = join-path -path $BasketFolder.Fullname -childpath "Log"     
	            } 
	                 
	            Save-Logfile $logPath $logFolder "Promote-File"
	        }
		}
    }
    
    Log_Message("End $($MyInvocation.MyCommand.Name)")
}

function Promote-File([string]$Path) {
<#
    .Synopsis
        moves file in to a folder of the name of the file
    .Example
        Promote-File c:\foo\bar.txt
        file "c:\foo\bar.txt will become c:\foo\bar\bar.txt
    .Parameter Path
        Path to file to be processed 
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Promote-Files
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [Path $Path]")
    
    #refrence to source object
    $file = get-item -LiteralPath $Path   

    #check if it is a file item
    if ($file.GetType().Name -eq 'FileInfo')
    {
        # Create the new folder same name as the file (minus the extension)
        $fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $promotedFolder = join-path -path $file.DirectoryName -childpath $fileBaseName
        $promotedFile = join-path -path $promotedFolder -childpath $file.Name
            
        write-verbose "expected outcome promoted file: $promotedFile"
      
        #check if folder exists     
        #if ((test-path -LiteralPath $promotedFolder -pathtype container) -eq $False)
        #{
        #    #if folder is not empty then  dont move.
        #    if ((get-childitem -LiteralPath $promotedFolder -recurse).count -gt 0)
        #    {
        #        write-error "Promotion folder already exists, not empty , skipping promotion"
        #    
        #        return
        #    }
        #}
        
        #create folder
        Write-Host("Promoted folder:", $promotedFolder)
        CreateDirectoryIfNeeded($promotedFolder)
        
        if ((test-path -LiteralPath $promotedFolder) -ne $True)
        {
            Write-error ("Was unable to create promotion folder, promotion failed")
            return
        }
        else
        {
            #move file in to promoted folder
            write-verbose "moving file in to folder"
            Move-Item -LiteralPath $file.FullName $promotedFolder -Force
        }
    
        #Check results
        if ((test-path -LiteralPath $promotedFile) -eq $False)
        {
            write-error "Promoted file does not exist, promotion failed"
        	return
        }
        else
        {
            #move file in to promoted folder
            Write-Host "Promotion successsfull"
            
            return $promotedFile
        }
    }     
    else
    {
        #move file in to promoted folder
        write-error "Object not a file, skipping promotion"
    }
    
    Log_Message("End $($MyInvocation.MyCommand.Name) : $($file:Name)")
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFvBEFX6pZ2ebuGiUtsNOPxRF
# rFygggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FHUQVejrWAd9rVlzKcmjDVI4PJ1GMA0GCSqGSIb3DQEBAQUABIGAEPNjX/GERoMA
# Nzy0zYDskfqL6HFSWnC/KqG0LgMfWICY+FPk1Hibr1chIhPhI2+lslCNiLkmOULh
# WJ2aEdVhVH3N4lX/czpTW/b8IIrj7IiKENsuC2Zk3U4vawPi/UxXiiFqujn1zBMY
# WE2hme0Xt93R5e1fNDkdh2hM++I8v5Y=
# SIG # End signature block
