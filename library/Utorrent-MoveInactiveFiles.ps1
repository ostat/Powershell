#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.5.1.7'
<#
Comments
    Checks the utorrent webui and move any items that are not active.

Change History
	Version 0.6.0.2
		Moved utorrent code to another script
	Version 0.5.1.0
		Fixed incorrect parenthisies ?Cookie?
	Version 0.5.0.0
	    Added comments 
	Version 0.4.0.0
	    improved title regexp to support titles with comma in them
	version 0.3.0.0
	    Added cookie support
	version 0.2.0.0
	    allow blank pass for guest account
	version 0.1.0.0
	    initial version
#>
function Utorrent-MoveInactiveFiles(
    [String]$utorrentFolder,
    [String]$destinationFolder
) {
<#
    .Synopsis
        checks the utorrent webui and move any items that are not active.
    .Example
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .Parameter utorrentFolder
        utorrent folder that will be scanned, should be path to completed or partial folders
    .Parameter destinationFolder
        place where inactive items will be moved
    .OUTPUTS
        None.
    .Notes
        NAME: MoveUtorrentInactiveFiles
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
    
    if ([string]::IsNullOrEmpty($utorrentFolder)) {
        write-error "input utorrentFolder is null. Exiting" 
        break
    }
    
    if ((test-path -LiteralPath $utorrentFolder -pathtype container) -eq $False) {
        write-error "folder utorrentFolder is invalid : '$utorrentFolder'. Exiting"
        break
    }
     
    if ([string]::IsNullOrEmpty($destinationFolder)) {
        write-error "input destinationFolder is null. Exiting" 
        break
    }
    
    if ((test-path -LiteralPath $destinationFolder -pathtype container) -eq $False) {
        write-error "folder destinationFolder is invalid : '$destinationFolder'. Exiting"
        break
    }
    
    $torrentList = @{};
    $torrentList = Utorrent-GetList
        
    if ($torrentList.count -gt 0)
    {
        #get list of files in completed folder
        Write-verbose ("`nChecking Folder")
             
        Get-ChildItem $utorrentFolder | ForEach-Object { 
            if ($torrentList.contains($_.Name ) -eq $false)
            {
                #"Moving " + $_.Name  
                Write-verbose ("CopyRemove-Folder(`"$($_.Name)`", `"$destinationFolder`")")
                CopyRemove-FileSystemItem $_.FullName $destinationFolder
            }
            else
            {
                Write-verbose ("Still active " + $_.Name )
            }
        }
    }
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4/XI97NP/n8IqyOg3MRpzp2c
# JkWgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FNA+t9NQWq6sWYhlATxXmztgqa7GMA0GCSqGSIb3DQEBAQUABIGArvmI3PLZmTEy
# CfckjQj99Gkmhe2AHPnh/4OmLjq3HZZGTYzdHK8eQSBpz7Fh2FqHafRsZe3hFR2L
# hCj/Tg04kXOFFSwdFE+wMGflyR7yIky8B879tinpCD+Pj4BSbKCpCgA2J+gjYwkm
# SKdHyyvx7rZO6TODP2B7iiMfUMvxwas=
# SIG # End signature block
