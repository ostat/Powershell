#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.4.0.7'

<#
Comments
    creates a back up of a folder
#> 

function Backup-Folder([string]$FolderPath)
{
<#
    .Synopsis
        Creates a back up of a folder
    .Description
    .Example
        Backup-Folder "C:\temp\folder1"
        creates a folder "C:\temp\folder1-backupyyyyMMdd-hhmm"
    .Parameter FolderPath
        Path of folder that will be backed up
    .INPUTS
        None. You cannot pipe objects to Backup-Folder.
    .OUTPUTS
        None.
    .Notes
        AUTHOR: max
        LASTEDIT: 19/04/2011
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
  if (test-path -LiteralPath $FolderPath) {
	$FolderToCopy = Get-Item $FolderPath
	$newPath = Join-Path "$($FolderToCopy.Parent.FullName)" "$($FolderToCopy.Name)-backup_$((get-date).toString('yyyyMMdd-hhmm'))"
    
	write-host "copy $($FolderToCopy.FullName) to $newPath"
    
    copy -LiteralPath $FolderPath -Destination "$newPath" -Recurse -Force
  }
}

function Backup-FolderAsZip([string]$FolderPath)
{
  #TODO complete
  if (test-path -LiteralPath $FolderPath) {
	$FolderToCopy = Get-Item $FolderPath
	$newPath = Join-Path "$($FolderToCopy.Parent.FullName)" "$($FolderToCopy.Name)-backup_$((get-date).toString('yyyyMMdd-hhmm')).zip"
	Out-Zip $newPath $FolderToCopy
	#"copy $($FolderToCopy.FullName) to $newPath"
    #copy -LiteralPath $FolderPath -Destination "$newPath" -Recurse -Force
  }
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQGamOJlh9nz2xIIuKVgt+j/w
# 6vGgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FFRMiaUNy+tE2GvcfK+0A1CjbrG/MA0GCSqGSIb3DQEBAQUABIGAlDcRga7cwoeq
# kYE1qdRrMg0BS1Y7asETM7AYYlVVVhZ7Z7nu7TDbN4kEGVGofeLeyHVLiDAnt0bF
# Eqtrwzkc5rev4dw5d4JUZM0XkT7xB7CLMA6rBKeme3AgsMrWoOqoYUFxHuEA85fb
# y3nPHrOh0Ne0ELBUDNcjrnHsf5etvbw=
# SIG # End signature block
