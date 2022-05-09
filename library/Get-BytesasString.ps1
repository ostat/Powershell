#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.1.0.4'

function Get-BytesasString([long]$Bytes) {
<#
    .Synopsis
        Displays the bytes in a pretty way
    .INPUTS
        None. You cannot pipe objects to Get-BytesasString.
    .OUTPUTS
        None.
    .Notes
        NAME: Get-BytesasString
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-Verbose("$($MyInvocation.MyCommand.Name) v$Version [Bytes $Bytes]")

    if ($Bytes -gt 1073741823)
    {
        [Decimal]$size = $Bytes / 1073741824
        return "{0:##.##} GB" -f $size 
    }
    elseif ($Bytes -gt 1048575)
    {
        [Decimal]$size = $Bytes / 1048576
        return "{0:##.##} MB" -f $size
    }
    elseif ($Bytes  -gt 1023)
    {
        [Decimal]$size  = $Bytes / 1024
        return "{0:##.##} KB" -f $size
    }
    elseif ($Bytes -gt 0)
    {
        [Decimal]$size = $Bytes
        return "{0:##.##} bytes" -f $size
    }
    else
    {
        return "0 bytes";
    }

}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQ8D7PoksM3rBsBjn+XhSgfZF
# GE6gggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FB5HXLGzSNOC6cPW+NyIBMMOMwiPMA0GCSqGSIb3DQEBAQUABIGAC9x/lhjIGqmf
# kB2kh5wEGro9H/uBYp/LLSXa4lYpeaBo07YF3leU39prxtiBRZc9kL0cjgZ8W+uu
# etrl9o1TNrC3T0qE1ZD3/jfRRxDSw1crA1IEOihPXWSerH84u1WA3oGhwVGNj4eC
# OgxaK5U5UmwvjtgWgdQUE1NFMafpYKA=
# SIG # End signature block
