#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.2.0.4'

<#
Comments
    Extracts all the rar files in the folder
#>
function Extract-RARs-in-Folder([string]$Folder) {
<#
    .Synopsis
        Extracts all the rar files in the folder
    .Description
    .Example
        Extract-RARs-in-Folder C:\temp\
        would extract C:\temp\foo.rar and C:\temp\bar.rar
    .Parameter Folder
        Path of folder to be processed 
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None
    .Notes
        NAME: Extract-RARs-in-Folder
        AUTHOR: max
        LASTEDIT: 2011-01-01 08:42:12
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version : [Folder $Folder]")
    Log_Message("Action - Extract-RARs-in-Folder $Folder")
      
    #refrence to source folder
    $BasketFolder = get-item -LiteralPath $Folder   

    $rarFiles = get-Childitem -LiteralPath $BasketFolder.FullName -recurse |  
    where{$_.Name -match ".*(?:(?<!\.part\d\d\d|\.part\d\d|\.part\d)\.rar|\.part0*1\.rar)"} 
    
    foreach ($rarfile in $rarFiles){ 
        #if none are foung an empty object is returned filter these by checking if the object exists
        if ($rarfile.Exists -eq $true)
        {
            write-verbose "processing matched rar : $($rarfile.Name)"
            if ($rarfile.Directory.Name -ne "Trash" -and $rarfile.Directory.Name -ne "subs"  -and $rarfile.Directory.Name -ne "Subtitles" )
            { 
                #this is a hack needed because we remove rar files in the loop.
                #regexp should only match on  rar 1 riles
                if (Test-Path $rarfile.Fullname  ) 
                {
                    
                    #refrence to source folder
                    $logFolder = join-path -path $rarfile.Directory.Fullname -childpath "Log"
                    
                    #$logPath = Prepaire-New-logFile $logFolder "Extract-RAR-File"
                    $logPath = Create-TempLogFile "Extract-RAR-File"
            
                    Start-Transcript $logPath
                    
                    $result =  Extract-RAR-File $rarfile.FullName $true -debug 
                    
                    Stop-Transcript
                }
            }
            else
            {
                write-verbose "skipping item due to folder name$($_.FullName)"
            }
        }
    }
    
    Log_Message("Action End - Extract-RARs-in-Folder : $($BasketFolder.Name)")
}


# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUh6+SSloihAaplMCgkg29m775
# DligggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FLMyAp1Yd/Gmhn7wYH+DZxkjdV7BMA0GCSqGSIb3DQEBAQUABIGANp9UFQ0JQwl3
# ueb+HJ1F2fW273qSOs6ENPXmDiiOdtI60QbaWicF3um5tOqraIj281vFthy733Sh
# 4mE7S8ZA89bGjRSZEiVw+h+o35QupPjcEfCTW9By9Y5J/rE/U1wPnLeXn2FHzyIg
# Y2CGwl9lBVWkFwh1V22D+MsuqP9Fcng=
# SIG # End signature block
