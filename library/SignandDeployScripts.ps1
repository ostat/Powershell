#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.6.0.17'
<#
Comments
	Script management, for signing and deplyoing to production style enviroment
	
Note
	Only updated scripts previously signed with cert should be resigned.
	Only scrypts with version numbers should have version numbers updated.
		
	If script is open Script needs to be closed and reopened after editing or will resign will occure.
#>

#########################################################
#Load config from file
#########################################################
[xml]$Script:configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}
	
#currrent valid cert thumbprint
$Script:certThumbprint = Get-ConfigValue $configFile "Configuration.CertThumbprint"

#previous cert thumbprint, usefull when changing certs
$Script:previousCertThumbprint = Get-ConfigValue $configFile "Configuration.PreviousCertThumbprint"

function Sign-Script([string]$ScriptFile)
{
<#
    .Synopsis
        Signs a script using the configured cert
		If scrips is resigned, the version number is updated, I.E. 1.0.0.*
    .Example
        Sign-Script "C:\devfolder\scriptfile.ps1"
        Signs the script "C:\devfolder\scriptfile.ps1"
    .Description
        Script must have a valid cert
    .Parameter ScriptFile
        Script file to be signed
    .Notes
        NAME: Sign-Script
        AUTHOR: max
        LASTEDIT: 31/13/2011 11:00:00
        KEYWORDS:
    .Link
        Http://www.ostat.com      
#>
    if (!(Test-Path $ScriptFile)) {
        Write-Error "Source file does not exist $ScriptFile" 
        return
    }
   
    Write-Host "Signing script $($ScriptFile)"
    
    #get version and updated it
    #[string]$filecontent = Get-Content -LiteralPath $ScriptFile
    
    [string]$filecontent = [System.IO.File]::ReadAllText($ScriptFile)
    
    if (($filecontent -match "Script:Version.*?=.*?'(?<version>.*?[^'])'") -eq $true)
    {
        #$Version
        [string]$currentVersion = $matches["version"]
        [string]$OuterMatch = $matches[0]
        
        #update version
        [int]$build = $currentVersion.Substring($currentversion.LastIndexOf(".") + 1, $currentversion.Length - $currentversion.LastIndexOf(".") - 1)
		$build ++
		
        [string]$newCurrentVersion = "$($currentVersion.Substring(0, $currentversion.LastIndexOf('.') + 1 ))$build"
        [string]$NewOuterOuterMatch = $OuterMatch.Replace($currentVersion, $newCurrentVersion)
                   
        $filecontent = $filecontent.Replace($OuterMatch,$NewOuterOuterMatch)
        Write-Host "  updating version From '$currentVersion' to '$newCurrentVersion'"
        Set-Content -LiteralPath $ScriptFile -Value $filecontent
        
    }
    
    $fileSignature = Set-AuthenticodeSignature $ScriptFile @(Get-ChildItem cert:\CurrentUser\My -codesigning)[0]
    
    return $fileSignature
}

function Deploy-Script([string]$SourceFilePath, [string]$TargetFolderPath)
{
<#
    .Synopsis
        deploys script file to the Target folder
    .Example
        Deploy-Script "C:\devfolder\lib\scriptfile.ps1" "\\server\powershellProfile\lib\"
        Copys the file from C:\devfolder\lib\scriptfile.ps1 to \\server\powershellProfile\lib\scriptfile.ps1"
    .Description
        Checks if cert is correct and source and target files are different
    .Parameter SourceFilePath
        script file to be copied
    .Parameter TargetFolderPath
        Path to deploy script to
    .Notes
        NAME: Deploy-Script
        AUTHOR: max
        LASTEDIT: 31/13/2011 11:00:00
        KEYWORDS:
        FutureDev: Create filder if needed
    .Link
        Http://www.ostat.com
#>
    if (!(Test-Path $SourceFilePath)) {
        Write-Error "Source file does not exist $SourceFilePath" 
        return
    }
   
    CreateDirectoryIfNeeded($TargetFolderPath)

    $file = Get-Item $SourceFilePath;
  
    $fileSignature = Get-AuthenticodeSignature $file.Fullname
 
    if ($fileSignature.Status -eq "Valid" -and $fileSignature.SignerCertificate.Thumbprint -eq $certThumbprint)
    {
        $targetFilePath = join-path $TargetFolderPath $file.Name
        
        #Compare source and target files, only copied if file changed
        if (!(Test-Path $targetFilePath) -or (Compare-Object ($file) (Get-Item $targetFilePath) -Property Name, Length, LastWriteTime -passThru | Where-Object { $_.SideIndicator -ne '==' }).count -eq 2 )
        {
   	    	Write-Host "deploying script $($file.Fullname) to $targetFilePath"
            copy -LiteralPath $SourceFile -Destination $targetFilePath -Force
        }
        
    }
}

function Deploy-Scripts([string]$WorkingFolder, [string]$TargetFolder)  
{
<#
    .Synopsis
        deploys all the scripts in a folder to network profile folders
    .Example
        Deploy-Scripts "C:\bin\powershell"
    .Description
        Script must have a valid cert
    .Parameter TargetFolder
        Target profile folder
    .Notes
        NAME: Deploy-Scripts
        AUTHOR: max
        LASTEDIT: 31/13/2011 11:00:00
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    if (!(Test-Path $WorkingFolder)) {
        Write-Error "Working folder does not exist $WorkingFolder" 
        return
    }

    if (!(Test-Path $TargetFolder)) {
        Write-Error "target path does not exist $TargetFolder" 
        return
    }

    Get-ChildItem -LiteralPath $WorkingFolder -Filter "*.ps1" -Recurse | foreach-object {
 
        $fileSignature = Get-AuthenticodeSignature $_.Fullname
 
        if ($fileSignature.Status -eq "Valid" -and $fileSignature.SignerCertificate.Thumbprint -eq $certThumbprint)
        {
            #Copy all files over, it might be better to only copy files that were signed
			$targetFolderPath = $_.Parent.Fullname.replace($WorkingFolder, $TargetFolder)
			Deploy-Script $_.FullName $targetFolderPath
        }
    }
}

function SignandDeploy-Scripts([string]$WorkingFolder, [string]$TargetFolder) 
{ 
<#
    .Synopsis
        Signs and deploys all the scripts in a folder
    .Example
        SignandDeploy-Scripts
    .Description
        Script must have correct thumprint (way if filtering test scripts)
        Signature will be updated if hash mismatch
        Always works on the "workingprofile"
    .Parameter
    .Notes
        NAME: SignandDeploy-Scripts
        AUTHOR: max
        LASTEDIT: 31/13/2011 11:00:00
        KEYWORDS:
        FutureDev: update version number (only if signature is invalid)
    .Link
    Http://www.ostat.com
#> 
    Write-Host "Signing and deploying powershell scripts. Only files already signed with the current cert (and edited) will be signed`nWorking folder $workingProfile" -background "black" -ForegroundColor "yellow"

    if (!(Test-Path $WorkingFolder)) {
        Write-Error "Working folder does not exist $WorkingFolder" 
        return
    }

    if (!(Test-Path $TargetFolder)) {
        Write-Error "target path does not exist $TargetFolder" 
        return
    }

    Write-Host "$($MyInvocation.MyCommand.Name) v$Version at: $(get-date)"
	
    #Back up working folder
    Write-Host "`nBackin up scripts"
    Backup-Folder  $WorkingFolder
    Write-Host ""
    Get-ChildItem -LiteralPath $WorkingFolder -Filter "*.ps1" -Recurse | foreach-object {
    	$sourceFile = $_.Fullname
        $fileSignature = Get-AuthenticodeSignature $sourceFile
        if ($fileSignature.SignerCertificate.Thumbprint -eq $previousCertThumbprint)
        {
            #update code signed to new signing certificate
            $fileSignature = Sign-Script $sourceFile
        }       
           
        if ($fileSignature.Status -eq "HashMismatch" -and $fileSignature.SignerCertificate.Thumbprint -eq $certThumbprint)
        {
            #update version number
            $fileSignature = Sign-Script $sourceFile
        } 
           
        if ($fileSignature.Status -eq "Valid" -and $fileSignature.SignerCertificate.Thumbprint -eq $certThumbprint)
        {
            #Copy all files over
			$targetFolderPath = $_.Directory.Fullname.replace($WorkingFolder, $TargetFolder)
			
            Deploy-Script $sourceFile $targetFolderPath
        }
        else
        {
            Write-Verbose "File not valid for deploying $sourceFile"
        }
    }
}

#SignandDeploy-UbikScriptProfiles  
#Sync-UbikScriptProfiles "C:\bin\powershell"

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUK1Lwxzx+Bq/IOQ2PIKGDtMRC
# SKOgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FEFmHnTMf1RAxL8spF1/xHNulkA4MA0GCSqGSIb3DQEBAQUABIGAMBZlQuc356mv
# dlRUPfXoX7xE1mOMb3B8OOAQGakldOnj9IdezwT0aXZM7WoRRuAzRRkGbJn0FpOB
# i+Epc0Gb/ZO+txrziHFWzLGaLLIgTJYsAn194EoU21V2kKP5BgrbaPBjgPCJTDBy
# JJxJoPzr9qfs4Tm4xPw77/6fmkHyDYY=
# SIG # End signature block
