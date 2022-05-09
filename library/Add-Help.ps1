#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '1.0.0.4'
<#
Comments
    Common helper scripts
#>

Function Add-Help
{
<#
    .Synopsis
        creates the a help template where the cursor is 
		Saves time adding help
    .Example
        Add-Help
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Add-Help
        AUTHOR: blog i cant recal
        LASTEDIT: 12/14/2010 20:53:20
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
 $helpText = @"
<#
    .Synopsis
        This the script does? 
    .Description
    .Example
        Example
        Example accomplishes 
    .Parameter 
        parameterDeets 
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        System.String.
    .Notes
        NAME: Example-
        AUTHOR: $env:username
        LASTEDIT: $(Get-Date -f "yyyy-MM-dd HH:mm:ss")
        KEYWORDS:
    .Link
        Http://www.ostat.com
#Requires -Version 2.0
#>
    Write-verbose ("`$(`$MyInvocation.MyCommand.Name) v`$Version : [Param `$Param]")
"@
 $psise.CurrentFile.Editor.InsertText($helpText)
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAysL3ZFVM6TfxhSHY6BQVGax
# vC+gggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FOLRHty0pX+qrg25ByMpZER1+1QlMA0GCSqGSIb3DQEBAQUABIGAi0+oQZ2jappY
# kbsgRyrIO6X91yI3+mMtHpduWYj4mwQb1jib7S693nAfSJNLntQxxnNPTkwomqwh
# Pr92QlF87bOg/T9zDpOcfthAu3ilk8Z0tdTlpsHk4h+QOJ2ELdgBb0MARykj15Yo
# BRQ/1CDhGP0I4Xw/5i3urZiln2pfraQ=
# SIG # End signature block
