#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.1.0.3'
<#
Comments
	Message XBMC
	http://wiki.xbmc.org/index.php?title=JSON_RPC

	$Url = 'http://10.0.0.77:8080/jsonrpc'
	$Data = '{ "jsonrpc": "2.0", "method": "GUI.ShowNotification", "params": { "title": "Windows Home Server", "message": "The server has booted, Enjoy", "displaytime": 10000 } }'

#>

function Message-XBMC {
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$IpAddress,
    [String]$Port,
	[String]$Title,
    [String]$Message)

     if(Test-Connection $IpAddress -Count 1 -Quiet)
    {
	    $Url = "http://$($IpAddress):$($Port)/jsonrpc"
	    #$Data = '{ "jsonrpc": "2.0", "method": "GUI.ShowNotification", "params": { "title": "Windows Home Server", "message": "The server has booted, Enjoy", "displaytime": 10000 } }'
	    $Data = "{ `"jsonrpc`": `"2.0`", `"method`": `"GUI.ShowNotification`", `"params`": { `"title`": `"$($Title)`", `"message`": `"$($Message)`", `"displaytime`": 10000 } }"
        Write-Host "Messaging XBMC on $Url"
    
        try
        {
	        New-RestItem  -Url $url -Data $Data
        }
        catch 
        {
            Write-Host "Message failed Error: $_"
        }
    }
    else
    {
       write-host "Cant Connect to XBMC on $IpAddress";
    }
}

function New-RestItem {
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url,
    [String]$Data,
    [TimeSpan]$Timeout = [System.TimeSpan]::FromMinutes(1)
)    
    Add-Type -AssemblyName System.Web
  
    try{
        $webReq = [System.Net.WebRequest]::Create($Url)
        $webReq.ContentType = 'application/json'
        #$webReq.Timeout = $Timeout.TotalMilliseconds
        $result = $null

        if($Data -ne $null)
        {
            $webReq.Method = 'POST'
            $bytes = [System.Text.Encoding]::ASCII.GetBytes($Data)
            $webReq.ContentLength = $bytes.Length
            $requestStream = $webReq.GetRequestStream()
            $requestStream.Write($bytes,0,$bytes.Length)
            $requestStream.close()
        }
        else
        {
            $webReq.Method = 'GET'
        }
        $responseStream = New-Object System.IO.Streamreader -ArgumentList $webReq.GetResponse().GetResponseStream()
        $responseStream.ReadToEnd()
        $responseStream.Close()

        Write-Verbose $responseStream
        Write-Output $responseStream.StatusCode

    }
    catch [System.Net.WebException]{
        if ($_.Exception -ne $null -and $_.Exception.Response -ne $null) {
            $errorResult = $_.Exception.Response.GetResponseStream()
            $errorText = (New-Object System.IO.StreamReader($errorResult)).ReadToEnd()
            Write-Warning "The remote server response: $errorText"
            Write-Output $_.Exception.Response.StatusCode
        } else {
            throw $_
        }
    }   
}


# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9wyrIZYGS8rgo2Q7Ft5sd6cA
# brOgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FL7RQ1Qgsb2yt+sPU/8eAJIbpM3EMA0GCSqGSIb3DQEBAQUABIGAaF30WzdP3YFf
# +mslKkqRBtq3zwQvfzNbN2EF8Fvwz4G9eSez9vhMwfeysRHSWkkypsy1FUiKTDam
# tCEnKPaq8wl3KSi++Ps7+c5UvkSsjogRC2Z4oXdThm9hPckwD0c8pATRkrrikGHa
# OXhO2rL+hEp0cU1m8DmYMutPENtmSeU=
# SIG # End signature block
