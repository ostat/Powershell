#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.2.0.4'
<#
Comments
    gets the folder size recursive

Change History
version 0.2.0.0
    Added comments 
version 0.1.0.0
    First version
#>

function Get-FolderSize([string]$FolderPath) {
<#
    .Synopsis
        gets the folder size recursive
    .Example
        [long]$result = Get-FolderSize "C:\temp"
    .Parameter Source
    .INPUTS
        None. You cannot pipe objects to Get-FolderSize.
    .OUTPUTS
        None.
    .Notes
        NAME: Get-FolderSize
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-Verbose("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")

    [long]$FolderLength = (Get-ChildItem -LiteralPath $FolderPath -Recurse | Measure-Object -Property Length -Sum).Sum
    return $FolderLength 
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUv9lF7JhBiHlkDvihTljn4pd7
# Rn+gggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FLOjY9u9WxkD8kglgi+GtBUoCqtPMA0GCSqGSIb3DQEBAQUABIGAl6OqjPZuf551
# pNSYNDyxwjPdLPXhzBNvnlzA3ilMs+gjpDO3VGcmTH5aT+iNpVPOsNFjWiG2R/Lu
# lDP/JK36Y6pjybLR09ngVnYoYArWSdmBv/WiJAXKZXDYhhApJD+EXQN6ogWS1Vsc
# vUsSyGWSmh5J2WaJVt8JvmC6AgOERlM=
# SIG # End signature block
