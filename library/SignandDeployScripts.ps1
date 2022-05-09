#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.6.0.12'
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
[xml]$configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}
	
#currrent valid cert thumbprint
$certThumbprint = $configFile.Configuration.CertThumbprint 

#previous cert thumbprint, usefull when changing certs
$previousCertThumbprint = $configFile.Configuration.PreviousCertThumbprint 

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
    $file = Get-Item $SourceFilePath;
    
    if (!(Test-Path $TargetFolderPath)) {
        Write-Error "target path does not exist $TargetFolderPath" 
        return
    }
    
    $fileSignature = Get-AuthenticodeSignature $file.Fullname
 
    if ($fileSignature.Status -eq "Valid" -and $fileSignature.SignerCertificate.Thumbprint -eq $certThumbprint)
    {
        $targetFilePath = join-path $TargetFolderPath $file.Name
        
        #Compare source and target files, only copied if file changed
        if (!(Test-Path $targetFilePath) -or (Compare-Object ($file) (Get-Item $targetFilePath) -Property Name, Length, LastWriteTime -passThru | Where-Object { $_.SideIndicator -ne '==' }).count -eq 2 )
        {
   	    	Write-Host "deploying script $($file.Fullname) to $TargetPath"
            copy -LiteralPath $SourceFilePath -Destination $targetFilePath -Force
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
    .Parameter TargetPathFolder
        Target profile folder
    .Notes
        NAME: Deploy-Scripts
        AUTHOR: max
        LASTEDIT: 31/13/2011 11:00:00
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
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
    Write-Host "$($MyInvocation.MyCommand.Name) v$Version at: $(get-date)"
	
    #Back up working folder
    Write-Host "`nBackin up scripts"
    Backup-Folder  $WorkingFolder
    Write-Host ""
    Get-ChildItem -LiteralPath $WorkingFolder -Filter "*.ps1" -Recurse | foreach-object {
        
        $fileSignature = Get-AuthenticodeSignature $_.Fullname
        if ($fileSignature.SignerCertificate.Thumbprint -eq $previousCertThumbprint)
        {
            #update code signed to new signing certificate
            $fileSignature = Sign-Script $_.Fullname
        }       
           
        if ($fileSignature.Status -eq "HashMismatch" -and $fileSignature.SignerCertificate.Thumbprint -eq $certThumbprint)
        {
            #update version number
            $fileSignature = Sign-Script $_.Fullname
        } 
           
        if ($fileSignature.Status -eq "Valid" -and $fileSignature.SignerCertificate.Thumbprint -eq $certThumbprint)
        {
            #Copy all files over
			$targetFolderPath = $_.Parent.Fullname.replace($WorkingFolder, $TargetFolder)
            Deploy-Script $_.FullName $targetFolderPath
        }
        else
        {
            Write-Verbose "File not valid for deploying $($_.Fullname)"
        }
    }
}