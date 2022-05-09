#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '1.0.0.6'

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

function Get-ConfigValue ([xml]$Config, [string]$Path) {
<#
    .Synopsis
        gets the config value
    .Example
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
if ($configFile -eq $null) {
  	Write-Error "config is null`nExiting"
	return}

    $message = "Config $($Path.Split(".")[-1]) :"
    $working = $Config
    $Path.Split(".") | ForEach-Object {
        if($working[$_] -ne $null)
        {
            $working = $working[$_]
        }
        else
        {
            $working = $null
        }
    }

    if($working -ne $null -and $working.InnerText -ne $null -and [string]::IsNullOrEmpty($working.InnerText) -eq $false)
    {
        Write-Host -ForegroundColor DarkGreen "`t$message $($working.InnerText)"
        return $working.InnerText
    }
    else
    {
        Write-Host -ForegroundColor DarkRed "`t$message Not found $Path"
        return ''
    }
}

function Get-ConfigValueForFilePath ([xml]$Config, [string]$Path) {
<#
    .Synopsis
        gets the config value
    .Example
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
if ($configFile -eq $null) {
  	Write-Error "config is null`nExiting"
	return}

    $message = "Config $($Path.Split(".")[-1]) :"
    $working = $Config
    $Path.Split(".") | ForEach-Object {
        if($working[$_] -ne $null)
        {
            $working = $working[$_]
        }
        else
        {
            $working = $null
        }
    }

    if($working -ne $null -and $working.InnerText -ne $null -and [string]::IsNullOrEmpty($working.InnerText) -eq $false)
    {
        if ([string]::IsNullOrEmpty($working.InnerText) -or (Test-Path -LiteralPath $working.InnerText) -ne $true)
	    {
	        Write-Host -ForegroundColor DarkRed "`t$message Path does not exist : $($working.InnerText)"
        }
        else
        {
            Write-Host -ForegroundColor DarkGreen "`t$message $($working.InnerText)"
        }

        return $working.InnerText
    }
    else
    {
        Write-Host -ForegroundColor DarkRed "`t$message Not found $Path"
        return ''
    }
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcTY4UoYmcw2YptCBjAPKi0jk
# Jk6gggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FPU8eqKbtZZfSjXqATePUd118u7ZMA0GCSqGSIb3DQEBAQUABIGAcF9B/oIkmbMS
# mT6gkgDgD/4rVq6ot6YZ2BFGlBQuCWPLcqkUeF6W6qev360MYfPGflFUl22AGDSJ
# tSzkBENj2OKD10q2DSPkfzLuqUhOJ8b3pQXikwwyBuq8gCsHP9XgCVDkbdzBZhdt
# YxsXBapAnnZLiBpKLR4x3d/wyi2UGrw=
# SIG # End signature block
