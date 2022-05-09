#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.1.0.6'
<#
Comments
    Enables easier comunication with utorrent via the webapi

Change History
	version 0.1.0.0
	    initial version
#>

#########################################################
#Load config from file
#########################################################
[xml]$configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}

[String]$Script:Server = $configFile.Configuration.Server 
[String]$Script:Port = $configFile.Configuration.Port
[String]$Script:User = $configFile.Configuration.User 
[String]$Script:Pass = $configFile.Configuration.Pass

[String]$Script:UtorrentUrl = "http://$server`:$port/gui/"
[String]$Script:token = ""
$Script:webClient = $null

function Utorrent-HttpGet([string]$Comand)
{
    if ([string]::IsNullOrEmpty($token) -eq $true -or $Script:webClient -eq $null) 
    {
        $webClient = new-object System.Net.WebClient
        $webClient.Headers.Add("user-agent", "PowerShell Script")
    
        Write-Verbose "utorrent address $UtorrentUrl"
        if ([string]::IsNullOrEmpty($User) -eq $false) 
        {
            $webClient.Credentials = new-object System.Net.NetworkCredential($User, $Pass)
            Write-Verbose "credentials added to webclient "
        }

        $responce = $webClient.DownloadString($UtorrentUrl + "token.html")
        [string]$cookies =  $webClient.ResponseHeaders["Set-Cookie"]

        if ($responce -match ".*<div[^>]*id=[`"`']token[`"`'][^>]*>([^<]*)</div>.*")
        {
            $token = $matches[1]
            $webClient.Headers.Add("Cookie", $cookies)
	    }
    }
    $url = "$($UtorrentUrl)?$($Comand)&token=$($token)"
    Write-Host ("Calling url`t$url")
    $response = $webClient.DownloadString($url)
    $json = ConvertFrom-JSON $response
    if($json.build -ne $null)
    {
        Write-Host ("Success $($json.build)")
    }
    return $json
}

function Utorrent-GetList() 
{
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$dict = @{};
    $json = Utorrent-HttpGet "list=1"
    $json.torrents | Foreach-Object {
        $dict.add($_[2],$_)
    } 
    $dict 
}

function Utorrent-GetSettings() 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$dict = @{};
    $json = Utorrent-HttpGet "action=getsettings"
    $json.settings | Foreach-Object {
        $dict.add($_[0],$_)
    } 
    $dict
}

function Utorrent-SetSettings([string]$setting, [string]$value) 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
    $json = Utorrent-HttpGet "action=setsetting&s=$setting&v=$value"
}

function Utorrent-GetTorrentFiles([string]$torrentHash) 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$dict = @{};
    $json = Utorrent-HttpGet "action=getfiles&hash=$torrentHash"
    $json.files | Foreach-Object {
        $dict.add($_[0],$_)
    } 
    $dict
}

function Utorrent-GetTorrentProps([string]$torrentHash) 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$dict = @{};
    $json = Utorrent-HttpGet "action=getprops&hash=$torrentHash"
    $json.props | Foreach-Object {
        $dict.add($_[0],$_)
    } 
    $dict
}

function Utorrent-SetTorrentProps([string]$torrentHash, [string]$property, [string]$value) 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$json = Utorrent-HttpGet "action=setprops&hash=$torrentHash&s=$property&v=$value"
}

function Utorrent-ParseSettings([string]$json) 
{
	if ([string]::IsNullOrEmpty($json) -eq $false -and $jayson[0] -eq "{")
    {
        return ConvertFrom-Json $json
    }
}



# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjeK683iLD5+FqUfT1gVKMeml
# h6ygggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FPBUs+KxAKqch0Jk4Ta1KCIgtzSrMA0GCSqGSIb3DQEBAQUABIGAof06E291QeaM
# durfsBM9Mqiwk007ca+uPKiRRUVdO/kWW6vlOkyuiwzI5bftJGnTWZnufSI4XEd+
# mkSW3jJtGP66l8HiAFYcNMYwLg7qDKi1NcSPUE0WeJUyfqhs486f/Vn/kK6DH+fH
# pF3sIn6blicY7daV7u7iDFYkzrzx1QA=
# SIG # End signature block
