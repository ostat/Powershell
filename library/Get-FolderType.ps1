#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.6.0.2'
<#
Comments
    Folder Type helper functions

Change History
version 0.6.0.0
    Added comments 
version 0.5.0.0
    Added set and get folder type
version 0.4.0.0
    case insensativity of name check
    comment improvements
version 0.3.0.0
    First version
#>

#
function Set-FolderType([string]$FolderPath, [string]$Type, [string]$Setter) {
<#
    .Synopsis
        Set sets the folder type, saving to the xml file
    .Example
        Set-FolderType C:\temp\foobar 'music' 'automatedscript'
    .Parameter Source
    .Parameter Destination
    .INPUTS
        None. You cannot pipe objects to Set-FolderType.
    .OUTPUTS
        None.
    .Notes
        NAME: Set-FolderType
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-Verbose("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath, type $Type, Setter $Setter]")
    
	#load folder xml file.
	[xml]$folderXML = Get-FolderXml $FolderPath
	
	#get the type node
	$node = SelectorCreate-XMLNode "Type" $folderXML.Folder 
	
	#set values        
	$node.set_innerText($Type)
	$node.SetAttribute("setter",$Setter)
	
	#save folder.xml
    Save-FolderXml $FolderPath $folderXML
}


function Get-FolderType([string]$FolderPath) {
<#
    .Synopsis
        returns the folder type
    .Example
        Get-FolderType C:\temp\foobar
        get the folder type for the item folder foobar
    .Parameter FolderPath
    .INPUTS
        None. You cannot pipe objects to Get-FolderType.
    .OUTPUTS
        None.
    .Notes
        NAME: Get-FolderType
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-Verbose("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")

	#load folder xml file.
	[xml]$folderXML = Get-FolderXml $FolderPath
	
	#get the type node
	$node = SelectorCreate-XMLNode "Type" $folderXML.Folder
    
	return $node.InnerText
}

#
function Detect-FolderType([string]$ItemPath)  {
<#
    .Synopsis
        autodetects the folder type
        Dont pass in list foler paths
    .Example
        Detect-FolderType C:\temp\foobar
    .Parameter ItemPath
        Path of item folder that will be checked.
    .INPUTS
        None. You cannot pipe objects to Detect-FolderType.
    .OUTPUTS
        None.
    .Notes
        NAME: MovDetect-FolderType
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [ItemPath $ItemPath]")
    
    if ([string]::IsNullOrEmpty($ItemPath) -eq $true -or (test-path -LiteralPath $ItemPath) -ne $True)
    {
        Write-Error("Item does not exist or is blank : '$ItemPath'")
        return
    }  
    
    #refrence to source folder
    $Folder = get-item -LiteralPath $ItemPath 
    
    $ExclusionPattern = "log|txt|nfo|sfv"

    #check for adult
    $resutXXX = 0
    if ($Folder.Name.ToUpper().Contains("XXX"))
    {
        $resutXXX = 100
    }
    
    #picture
    $InclusionPatternPictures = ".*\.(png|jpg|jpeg|bmp|gif|ico|tif|tiff|tga|pcx)$"
    $resutPicture = Get-CheckFolderForFiles $Folder.FullName $InclusionPatternPictures $ExclusionPattern 0 
    
    #music
    $InclusionPatternMusic = ".*\.(nsv|m4a|flac|aac|strm|pls|rm|mpa|wav|wma|ogg|mp3|mp2|mod|amf|669|dmf|dsm|far|gdm|imf|it|m15|med|okt|s3m|stm|sfx|ult|uni|xm|sid|ac3|dts|cue|aif|aiff|wpl|ape|mac|mpc|mp+|mpp|shn|wv|nsf|spc|gym|adplug|adx|dsp|adp|ymf|ast|afc|hps|xsp)$"
    $resutMusic = Get-CheckFolderForFiles $Folder.FullName $InclusionPatternMusic $ExclusionPattern 0 
    
    #Video
    $InclusionPatternVideo = ".*\.(m4v|3gp|nsv|ts|ty|strm|rm|rmvb|ifo|mov|qt|divx|xvid|bivx|vob|nrg|wmv|asf|asx|ogm|m2v|avi|dat|dvr-ms|mpg|mpeg|mp4|mkv|avc|vp3|svq3|nuv|viv|dv|fli|flv)$"
    $resutVideo = Get-CheckFolderForFiles $Folder.FullName $InclusionPatternVideo $ExclusionPattern 0 
    
    $total = $resutPicture + $resutMusic + $resutVideo + $resutXXX
        
    $TargetFolder = $null
    if($resutXXX -eq 100)
    {
        $DetectedType = "xxx"
    }
    elseif($resutPicture -gt 90 -and $total -lt 110 )
    {
        $DetectedType = "picture"
    }
    elseif($resutVideo -gt 90 -and $total -lt 110 )
    {
        $DetectedType = "video"
        
    }
    elseif($resutMusic -gt 90 -and $total -lt 110 )
    {
        $DetectedType = "music"
    }
    else
    {
        $DetectedType = "unknown"
        Log_Message("picture " + $resutPicture)
        Log_Message("music " + $resutMusic)
        Log_Message("Video " + $resutVideo)
        Log_Message("xxx " + $resutXXX)
        Log_Message("total " + $total)
    }

    Log_Message("found $DetectedType")
    
    Set-FolderType $Folder.FullName $DetectedType "auto"
}

function Get-CheckFolderForFiles([string]$FolderPath, [string]$InclusionPattern, [string]$ExclusionPattern, [long]$MiniumFileSignificence)  {
<#
    .Synopsis
        determins the percentage of the non excluded files in the folder that match the inclusion patter
    .INPUTS
        None. You cannot pipe objects to Get-CheckFolderForFiles.
    .OUTPUTS
        None.
    .Notes
        NAME: Get-CheckFolderForFiles
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-Verbose("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")
    $incPattern = $InclusionPattern.Split(',')
    $excPattern = $ExclusionPattern.Split(',')

    #Count total files.
    $countAll = @(Get-ChildItem -LiteralPath $FolderPath -Recurse | where{!$_.PsIsContainer} | where{$_.name -notmatch $ExclusionPattern}).count
    #"All files " + $countAll
    if ($countAll -lt 1)
    { return 0 }
    #Count insignificent files
    #"insignificent files " + @(Get-ChildItem -literalpath $FolderPath -Recurse).count

    #count total files included.
    #"InclusionPattern files " + @(Get-ChildItem -literalpath $FolderPath -Recurse | where{!$_.PsIsContainer} | where{$_.name -match $InclusionPattern}).count

    #count number of excludedfiles.
    #"excludedfiles files " + @(Get-ChildItem -literalpath $FolderPath -Recurse | where{!$_.PsIsContainer} | where{$_.name -match $ExclusionPattern}).count

    $MatchCount = @(Get-ChildItem -literalpath $FolderPath -Recurse | where{!$_.PsIsContainer} | where{$_.name -notmatch $ExclusionPattern}| where{$_.name -match $InclusionPattern}).count
    #"Matched Files $MatchCount "

    #total-insignificient-exlcuded/included*100 = percentage match
    [Math]::Round($MatchCount/$countAll*100,2)
}


#so script can be called like so .\Get-FolderType.ps1 "C:\temp\imagestest"
#if (![string]::IsNullOrEmpty($FolderPath))
#{
#    AutoSortFolder $FolderPath
#} 
    
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBI+Wq9F387/ll7X428pBCjup
# 8+OgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FIf7M2RrMWdWJLjHSYg1sGvBiOYYMA0GCSqGSIb3DQEBAQUABIGAZsYfaQmkc6bN
# qvEkz78SJ8wjhi5kMN5wJrEBJC+4oVZ1aR/F/DPr76K0XwbT6eIbZO0cCF1vizTu
# IsfOM5I3HlDyZOKDQD2cK221yHNNO5bmANLBKagn34+P7+z7Oa3oHWcNvOD3UB71
# LZ9Rb6Aq1pmZ1IMeu1CyP8MA7JJGYtI=
# SIG # End signature block
