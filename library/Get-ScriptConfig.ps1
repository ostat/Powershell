#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '1.0.0.4'

function Get-ScriptConfig () {
<#
    .Synopsis
        gets the scripts config file
    .Example
        [xml]$result = Get-ScriptConfig "$($MyInvocation.MyCommand.ScriptName)"
    .Parameter Source
    .INPUTS
        None. You cannot pipe objects to get-ScriptConfig.
    .OUTPUTS
        None.
    .Notes
        NAME: Get-ScriptConfig
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
	#Get Calling scripts file name
	
	[string]$scriptPath = $MyInvocation.ScriptName
	$ParentFolder = Split-Path -Path $scriptPath -Parent 
	$ConfigFile = Join-Path $ParentFolder "$([System.IO.Path]::GetFileNameWithoutExtension($scriptPath)).config"
	
    if ([string]::IsNullOrEmpty($ConfigFile) -eq $true -or (Test-Path $ConfigFile) -eq $false) {
	  	Write-Error "Cound not find the config file $($ConfigFile)"
	}
  	else
	{
  		[xml]$config = Get-Content $ConfigFile
		return $config
  	}

}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWFAqvvKmDyYiRSdDN3g3Yjbv
# OTagggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FCnsOk47zkXrfKqr9Z9pNYpsvhZ4MA0GCSqGSIb3DQEBAQUABIGApZv7biRVVXuO
# YvkY00yc3EkUw97YQNvZ+buv5Ajsh6fRKgFgXAxn6/+r2EmCnwOQbcDWTV08EV9H
# 0znl1d0afs1YQeXpfyc66PTrS4Ad05msxoG/eBVtyZnQ9tFU80YPlkeiA45t+R0S
# Wck70adT9ZgcWf+MMF9LJSt345txBO8=
# SIG # End signature block
