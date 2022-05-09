#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.2.0.5'
<#
Comments
    Download Audio stream to local drive
	Requires access to a copy of mplayer.exe
	#mplayer's homepage is http://www.mplayerhq.hu
#>

#########################################################
#Load config from file
#########################################################
[xml]$configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}

#Local path to mplayer.exe
[string]$Script:MplayerPath = $configFile.Configuration.MplayerPath

function Get-Web($url, 
    [switch]$self,
    $credential, 
    $toFile,
    [switch]$bytes)
{
    #.Synopsis
    #    Downloads a file from the web
    #.Description
    #    Uses System.Net.Webclient (not the browser) to download data
    #    from the web.
    #.Parameter self
    #    Uses the default credentials when downloading that page (for downloading intranet pages)
    #.Parameter credential
    #    The credentials to use to download the web data
    #.Parameter url
    #    The page to download (e.g. www.msn.com)    
    #.Parameter toFile
    #    The file to save the web data to
    #.Parameter bytes
    #    Download the data as bytes   
    #.Example
    #    # Downloads www.live.com and outputs it as a string
    #    Get-Web http://www.live.com/
    #.Example
    #    # Downloads www.live.com and saves it to a file
    #    Get-Web http://wwww.msn.com/ -toFile www.msn.com.html
    #.source
    #    http://blogs.msdn.com/b/mediaandmicrocode/archive/2008/12/01/microcode-powershell-scripting-tricks-scripting-the-web-part-1-get-web.aspx
    $webclient = New-Object Net.Webclient
    if ($credential) {
        $webClient.Credential = $credential
    }
    if ($self) {
        $webClient.UseDefaultCredentials = $true
    }
    if ($toFile) {
        if (-not "$toFile".Contains(":")) {
            $toFile = Join-Path $pwd $toFile
        }
        $webClient.DownloadFile($url, $toFile)
    } else {
        if ($bytes) {
            $webClient.DownloadData($url)
        } else {
            $webClient.DownloadString($url)
        }
    }
}

function Save-Stream([string]$asxUrl, 
    [string]$saveFolder, 
    [string]$pathofUrl)
	#.Synopsis
    #    Downloads a file from the web
    #.Description
    #    Saves a stream to a file if it does not already exist locally.
    #.Parameter $asxUrl
    #    Url of asx file
    #.Parameter $saveFolder
    #    Folder path to save to
    #.Parameter $pathofUrl
    #    Xpath to the node with the href. the value of the first item is used
    #.Example
    #    # Downloads www.live.com and outputs it as a string
    #    Save-Stream http://www.test.com/test.asx c:\test\ "asx/entry/ref/@href"
{

    # Verify we can access mplayer.EXE .
	if ([string]::IsNullOrEmpty($MplayerPath) -or (Test-Path -LiteralPath $MplayerPath) -ne $true)
	{
	    Write-Error "mplayer.exe path does not exist '$MplayerPath'."
        return
    }
	
    CreateDirectoryIfNeeded $saveFolder
    
    #get urls to streams
    [xml]$asxXml = Get-Web $asxUrl  
    $streams = $null
    if ($asxXml -ne $null)
    {
        #$sourceStream = $asxXml.asx.entry.ref[0].href 
        $streams = $asxXml.SelectNodes($pathofUrl)
    }

    #Save first stream
    if($streams -ne $null -and $streams.Count -gt 0)
    {
        $sourceStream = $streams.Item(0).Value
        $fileName = "$($sourceStream.split('/')[-1])"
        $targetPath = Join-Path $SaveFolder $fileName

        #download file if it does not exist locally
        if((Test-Path $targetPath) -eq $false)
        {
            Write-Host "Downloading stream '$sourceStream' to '$targetPath'"
            &$MplayerPath -dumpstream -dumpfile $targetPath -cache 4096 $sourceStream 
        }
    }
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUm4tkxbuieGLzFtx4g5WxZjr
# ObCgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FHelpay2JsYRSj/Eloc2T7hn1FaCMA0GCSqGSIb3DQEBAQUABIGAV+imfvcufHqj
# egvUQNE9ANUU9uEnYW3qMOwBm5dKPhC+/RuSFW9EIMfFH95OKx3boMs0xAjkqJkh
# t90Bn0gmPQyn2mcyYg+WhdodQh/P/4K+7B+FicnTVs9dk7xrHUXCOPZHCkmviWgP
# ZovRGoH5HDibn7JiwLpNY2330Vcsy5g=
# SIG # End signature block
