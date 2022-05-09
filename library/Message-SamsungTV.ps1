#*******************************************************************
# Global Variables
#*******************************************************************
#requires -version 3.0
$Script:Version      = '0.1.0.3'
<#
Comments
	Sends message to Samsung TV (SMS)
	http://wiki.samygo.tv/index.php5/MessageBoxService_request_format
	
	#values
	$ipaddress = '10.0.0.15'
	$pmrUri = "http://$($ipaddress):52235/pmr/PersonalMessageReceiver.xml"
	$cUri = "http://$($ipaddress):52235/PMR/control/MessageBoxService"
	$eUri = "http://$($ipaddress):52235/PMR/event/MessageBoxService"
	$mbsUri = "http://$($ipaddress):52235/MessageBoxService.xml"
	$content = Get-Content "C:\temp\sammytest.txt"

	Message-SamsungTV -url $cUri -data $content -contentType "text/xml"
#>


function Message-SamsungTV()
{
  param(
    [string] $IpAddress = $null,
    [string] $Message = $null,
    [string] $Name = $null,
    [System.Net.NetworkCredential]$credentials = $null,
    [string] $ContentType = "application/x-www-form-urlencoded",
    [string] $CodePageName = "UTF-8",
    [string] $UserAgent = $null
  )

$data = @"
 <?xml version="1.0" encoding="utf-8"?>
  <s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" >
    <s:Body>
      <u:AddMessage xmlns:u="urn:samsung.com:service:MessageBoxService:1\">
        <MessageType>text/xml</MessageType>
        <MessageID>can be anything</MessageID>
        <Message>
          &lt;Category&gt;SMS&lt;/Category&gt;
          &lt;DisplayType&gt;Maximum&lt;/DisplayType&gt;
          &lt;ReceiveTime&gt;
          &lt;Date&gt;2010-05-04&lt;/Date&gt;
          &lt;Time&gt;01:02:03&lt;/Time&gt;
          &lt;/ReceiveTime&gt;
          &lt;Receiver&gt;
          &lt;Number&gt;12345678&lt;/Number&gt;
          &lt;Name&gt;$($Name)&lt;/Name&gt;
          &lt;/Receiver&gt;
          &lt;Sender&gt;
          &lt;Number&gt;11111&lt;/Number&gt;
          &lt;Name&gt;Sender&lt;/Name&gt;
          &lt;/Sender&gt;
          &lt;Body&gt;$($Message)&lt;/Body&gt;
        </Message>
      </u:AddMessage>
    </s:Body>
  </s:Envelope>
"@
  if ( $IpAddress -and $data )
  {
    if(Test-Connection $IpAddress -Count 1 -Quiet)
    {
        $url = "http://$($IpAddress):52235/PMR/control/MessageBoxService"
        [System.Net.WebRequest]$webRequest = [System.Net.WebRequest]::Create($url);
        $webRequest.ServicePoint.Expect100Continue = $false;
        if ( $credentials )
        {
          $webRequest.Credentials = $credentials;
          $webRequest.PreAuthenticate = $true;
        }
        $webRequest.ContentType = $contentType;
        $webRequest.Method = "POST";
        if ( $userAgent )
        {
          $webRequest.UserAgent = $userAgent;
        }
        #charset=\"utf-8\".
        $webRequest.Headers.Add('charset', '"utf-8"')
        $webRequest.Headers.Add('SOAPACTION', '"uuid:samsung.com:service:MessageBoxService:1#AddMessage"')

        $enc = [System.Text.Encoding]::GetEncoding($codePageName);
        [byte[]]$bytes = $enc.GetBytes($data);
        $webRequest.ContentLength = $bytes.Length;
        try
        {
            [System.IO.Stream]$reqStream = $webRequest.GetRequestStream();
            $reqStream.Write($bytes, 0, $bytes.Length);
            $reqStream.Flush();

            $resp = $webRequest.GetResponse();
            $rs = $resp.GetResponseStream();
            [System.IO.StreamReader]$sr = New-Object System.IO.StreamReader -argumentList $rs;
            $sr.ReadToEnd();
        }
        catch {
           write-host $_.Exception.Message;
        }
    }
    else
    {
       write-host "Cant Connect to SamsungTV on $ipaddress";
    }
  }
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqUjRRXIrIjzV7yzsiu0hwh6x
# r0egggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FAxEZuRZtNS5piNr8U5PAcLxmnwsMA0GCSqGSIb3DQEBAQUABIGAX3JbiYhGy4w0
# Zi36u+tBa6qDS3NyHRmihbgTas+zca+N1FVTqi7Y4+9SaJjD3vQT3B8QX0kLpWrL
# FZadrIMAe0ESNIqLbNlFdZUpAL4gKdmvJSvN7HteMSNwwptgdqGoptbGKWoPcw9B
# ttsAjTYX1CRGDLTWU5gUEAC+WHZ9LIk=
# SIG # End signature block
