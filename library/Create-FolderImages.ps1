#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '1.8.0.18'
<#
Comments
    Create thumbnails from video store in thumnbs dir.
    Copy random image from created to folder.jpg

Notes
	Bit of a mess needs a refactor
#>

#########################################################
#Load config from file
#########################################################
[xml]$configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}
	
$Script:MtuPath =  $configFile.Configuration.MtuExePath 
$Script:VideoFilesPattern = $configFile.Configuration.VideoFilesPattern
$Script:ItemSubFolders = $configFile.Configuration.ItemSubFolders


#########################################################
#functions
#########################################################
function Set-FolderImage([string]$ImageFilePath, [string]$FolderPath = $null) 
{
<#
    .Synopsis
        sets an image as the $FolderPath folder.img file
    .Description
        sets an image as the the folders folder.img file - $FolderPath\folder.img
        ImageFilePath,
        NOTE is not used by Set-FolderImage-Random as ramdom supports recurse 
    .Example
        Set-FolderImage "c:\folder\thums\image.jpg"
		would copy "image.jpg" to "c:\folder\folder.jpg"
    .Parameter ImageFilePath
	 	path to image that will become the folder.img (expected to be thumb\image.jpg)
    .Parameter FolderPath
		Path to folder. If null the path is image folder is used. 
		If image folder is "thums" or "covers" parent folder is used
    .INPUTS
        None. You cannot pipe objects to Set-FolderImage.
    .OUTPUTS
        None.
    .Notes
        NAME: Set-FolderImage
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:
		Need to work on the folder detection. This could be more dynamic.
    .Link
        Http://www.ostat.com

#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [ImageFilePath $ImageFilePath, FolderPath $FolderPath]")
	
    if ([string]::IsNullOrEmpty($ImageFilePath) -or (test-path -LiteralPath $ImageFilePath) -eq $False)
    {
        Write-Error "Image does not exist $ImageFilePath"
        return
    }
    
    $imageFile = Get-Item -LiteralPath $ImageFilePath
    
    if([string]::IsNullOrEmpty($FolderPath) -or (test-path -LiteralPath $FolderPath) -eq $False)
    {
        if($imageFile.Directory.name -match $ItemSubFolders)
        {
            $FolderPath = $imageFile.Directory.Parent.FullName 
        }
        else
        {
            $FolderPath = $imageFile.Directory.FullName 
        }
    }
    
    $FolderImage = join-path -Path $FolderPath -childpath "folder.jpg"
    
    #copy file to folder.jpg
    if ($imageFile -ne $null -and $imageFile.Exists)
    {
        copy-item -LiteralPath $imageFile.FullName -Destination $FolderImage -Force
    }
}

function Set-VideoThumbnailImage([string]$ImageFilePath, [string]$VideoFilePath = $null)  
{
<#
    .Synopsis
        Sets a specific image as the thumbnail for a video.
    .Description
        creates or overwrites a file called <folder>\<video>.tbm
    .Example
        Set-FolderImage "c:\folder\thums\image.jpg" "c:\folder\thums\video.avi"
		Would copy image.jpg to "c:\folder\thums\video.tbm"
    .Parameter ImageFilePath
		path to image that will become the video.tbm (expected to be thumb\image.jpg)
    .Parameter VideoFilePath
		Optional, video to set thumb for. If blank video will be in parent folder with matching name
    .INPUTS
        None. You cannot pipe objects to Set-VideoThumbnailImage.
    .OUTPUTS
        None.
    .Notes
        NAME: Set-FolderImage
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:
    .Link
        Http://www.ostat.com
#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [ImageFilePath: '$ImageFilePath', VideoFilePath: '$VideoFilePath']")
	
	if ([string]::IsNullOrEmpty($ImageFilePath) -or (test-path -LiteralPath $ImageFilePath) -eq $False)
    {
        Write-Error "Image does not exist $ImageFilePath"
        return
    }
   	$imageFile = Get-Item -LiteralPath $ImageFilePath
   	
	if ([string]::IsNullOrEmpty($VideoFilePath)) {
		#if no video was selected select one If the name of the file matches the pattern, and is in the parent folder.
		#pattern "<video>_00_06_08_00002"
		$imageFileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($imageFile.name)
		
		#get video name from thumbnail name
		$regexp = '^(?<videoname>.*)_\d{2}_\d{2}_\d{2}_\d{5}$'
		if ($imageFileNameWithoutExtension -match $regexp -eq $true)
		{
			#check if video exists in the parent folder.
			$count = 0
			$videoFileName = $Matches['videoname']
			
			Get-ChildItem -LiteralPath $imageFile.Directory.Parent.FullName |
			where{$_.name -match $VideoFilesPattern} | 
			foreach	{
				if([string]::IsNullOrEmpty($_.name) -eq $false -and $_.name.StartsWith($videoFileName, [StringComparison]::InvariantCultureIgnoreCase ))
				{
					$VideoFilePath = $_.fullname
					$count = $count + 1	
				}
			}
		}
	}
	
	if ([string]::IsNullOrEmpty($VideoFilePath) -or (test-path -LiteralPath $VideoFilePath) -eq $False)
    {
        Write-Error "video does not exist '$VideoFilePath'"
        return
    }
	
	$videoFile = Get-Item -LiteralPath $VideoFilePath
	
    $videoFileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($videoFile.name)
	#destination for image file
	$thumbnailPath =  join-path -path $videoFile.DirectoryName -childpath "$($videoFileBaseName).tbn"
	
    #copy file
    copy-item -LiteralPath $imageFile.FullName -Destination $thumbnailPath -Force
}

function Set-VideoThumbnailImage-Random([string]$VideoFilePath, [bool]$OverwriteExisting = $False) 
{
<#
    .Synopsis
        sets The video thumnail to a random one from the thumbs folder
    .Description
        sets random file as folder\video.tbn image.
        Image file will be selected from the thums dir, contactSheet will be excluded.
		Image filename must match video
    .Example
		Set-VideoThumbnailImage-Random "c:\folder\video.avi"
    .Parameter FolderPath
		folder
    .Parameter OverwriteExisting
		Force overwrite of an existing folder.xml (default = false)
    .INPUTS
        None. You cannot pipe objects to Set-VideoThumbnailImage-Random.
    .OUTPUTS
        None.
    .Notes
        NAME: Set-FolderImage
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:should not refrence .jpg
    .Link
        Http://www.ostat.com

#>
    #make random file the folder.jpg
        
	if ([string]::IsNullOrEmpty($VideoFilePath) -or (test-path -LiteralPath $VideoFilePath) -eq $False)
    {
        Write-Error "video does not exist $VideoFilePath"
        return
    }
	
	$videoFile = Get-Item -LiteralPath $VideoFilePath
	$videoFileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($videoFile.name)
	$thumbnailPath =  join-path -path $videoFile.DirectoryName -childpath "$($videoFileBaseName).tbn"
	
    if ((test-path -LiteralPath $thumbnailPath) -eq $False -or $OverwriteExisting -eq $True) 
    {
        $ThumbsFolderPath = join-path -path $videoFile.DirectoryName -childpath "thumbs"
       
        $newFile = get-childItem -LiteralPath $ThumbsFolderPath | 
            where{[System.IO.Path]::GetFileNameWithoutExtension($_.name).ToLower().StartsWith($videoFileBaseName.ToLower())} | 
            where{$_.name -match "jpg"} | 
            where{$_.name -notmatch "ContactSheet\.jpg"} |
            Get-Random
        
        #copy file to
        
        if ($newFile -ne $null -and $newFile.Exists)
        {
            Set-VideoThumbnailImage $newFile.FullName $VideoFilePath 
        }
    } 
}
	
function Set-FolderImage-Random([string]$FolderPath, [bool]$OverwriteExisting = $False, [bool]$Recurse = $False) 
{
<#
    .Synopsis
        sets an image as the the parent folders folder.img file
    .Description
        sets random file as folder image.
        File must be in the thums dir, and must not be called contactSheet.
        $OverwriteExisting will overwrite existing folder.xml (default = false)
        Recurse will recurce folders (default is false)
    .Example
    .Parameter FolderPath
    .Parameter OverwriteExisting
    .Parameter Recurse
    .INPUTS
        None. You cannot pipe objects to Set-FolderImage-Random.
    .OUTPUTS
        None.
    .Notes
        NAME: Set-FolderImage-Random
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:should not refrence .jpg
    .Link
        Http://www.ostat.com

#>
    #make random file the folder.jpg
    $FolderImage = join-path -path $FolderPath -childpath "folder.jpg"
        
    if ((test-path -LiteralPath $FolderImage) -eq $False -or $OverwriteExisting -eq $True) 
    {
        if($Recurse -eq $false)
        {
            $ThumbFolderPath = join-path -path $FolderPath -childpath "thumbs"
            $ThumbsFolders = get-item -LiteralPath $ThumbFolderPath 
        }
        else
        {
            $ThumbsFolders = get-childItem -LiteralPath $FolderPath -Include "thumbs" -Recurse | where{$_.PsIsContainer}
        }

        $newFile = $ThumbsFolders | 
            get-childItem | 
            where{$_.name -match "jpg"} | 
            where{$_.name -notmatch "ContactSheet\.jpg"} |
            Get-Random
        
        #copy file to folder.jpg
        
        if ($newFile -ne $null -and $newFile.Exists)
        {
            Set-FolderImage $newFile.FullName $FolderPath 
        }
    } 
}

function Create-Thumbnails([string]$FolderPath,[int]$rows = 15) 
{
<#
    .Synopsis
        Creates Thumbnails and, file.tbm, folder.jpg for select folders. Does not process child folder
    .Description
    .Example
    .Parameter FolderPath
    .Parameter $rows
		Number of rows in output thumbnail
    .INPUTS
        None. You cannot pipe objects to Create-Thumnails.
    .OUTPUTS
        None.
    .Notes
        NAME: Set-FolderImage
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:should not refrence .jpg
    .Link
        Http://www.ostat.com

#>
   	Write-Host("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")
   
    #Location where logs will be written
   		
	# Verify we can access Mtu.EXE .
	if ([string]::IsNullOrEmpty($MtuPath) -or (Test-Path -LiteralPath $MtuPath) -ne $true)
	{
	    Write-Error "Mtu.exe path does not exist '$MtuPath'."
        return
    }
	
    if ([string]::IsNullOrEmpty($FolderPath) -or (test-path -LiteralPath $FolderPath) -eq $False) 
    {
        Log_Message "ERROR | Folder does not exist: $FolderPath. Exiting"
        return
    } 

    $ThumbFolder = join-path -path $FolderPath -childpath "thumbs"
    $FolderImage = join-path -path $FolderPath -childpath "folder.jpg"
    
         
    #Process all video files in folder. All files where not a container, matches video pattern
    Get-ChildItem -LiteralPath $FolderPath | where{!$_.PsIsContainer -and $_.name -match $VideoFilesPattern} | ForEach-Object { 
        
	    #check for old file name (*_s.jpg, *folder.jpg) - remove old names for the contact sheet
	    $fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($_.name)
	    $oldname = join-path -path $_.Directory -childpath "$($fileBaseName)_s.jpg"
	    if (test-path -LiteralPath $oldname) 
	    {Remove-Item -LiteralPath $oldname}  
	    $oldname = join-path -path $_.Directory -childpath "$($fileBaseName)folder.jpg"
	    if (test-path -LiteralPath $oldname) 
	    {Remove-Item -LiteralPath $oldname}  
	    
	    Create-ThumbnailsForVideo -videoPath $_.FullName -edgeDetection 10 -rows $rows
        
		Set-VideoThumbnailImage-Random $_.FullName
    }
    
    #make random file the folder.jpg
    Set-FolderImage-Random $FolderPath
}

function Create-IntroThumbnailsForVideo([string]$videoPath,[double]$skip = 0.0) 
{
<#
    .Synopsis
        Creates Thumbnails for the first one min of movie
    .Description
    .Example
    .Parameter videoPath
		full path of movie file
    .Parameter skip
		number of seconds to skip in before imaging starts
    .INPUTS
        None. You cannot pipe objects to Create-Thumnails.
    .OUTPUTS
        None.
    .Notes
        NAME: Set-FolderImage
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:should not refrence .jpg
    .Link
        Http://www.ostat.com

#>
   	Write-Host("$($MyInvocation.MyCommand.Name) v$Version [VideoPath='$VideoPath', Skip='$skip']")

    Create-ThumbnailsForVideo -videoPath $videoPath -skip $skip -maximumSpaceBetween 120 -edgeDetection 20 -rows 30 -contactSheetName "-ContactSheet_Intro_$skip.jpg" 
}


function Create-ThumbnailsForVideo(
    [string]$videoPath,
    [double]$skip = 0.0,
    [int]$maximumSpaceBetween=-1,
    [int]$edgeDetection=12,
    [bool]$updateOnly=$true,
    [string]$contactSheetName,
    [int]$rows = 15
    ) 
{
<#
    .Synopsis
        Create thumnails and contactsheet for given video file
    .Description
        
    .Example
        Create thumnails for "c:\myMovie.avi" using default settings
        Create-ThumbnailsForVideo -videoPath "c:\myMovie.avi"
    
    .Example
         Create thumnails for "c:\myMovie.avi" Skiping ahead 5:12 mins, one shot every 2 mins
         Create-ThumbnailsForVideo -videoPath "c:\myMovie.avi" -skip (new-timespan -Minutes 5 -Seconds 12).TotalSeconds -maximumSpaceBetween 120
        
    .Parameter videoPath
		full path of movie file
    .Parameter edgeDetection
		12 : edge detection; 0:off >0:on; higher detects more; try 4 6 or 8
    .Parameter maximumSpaceBetween
		-1 : cut movie and thumbnails not more than the specified seconds; <=0:off
    .Parameter rows
		number of rows in the contact sheet. Number of thumbnails are rows*cols. cols = 2.
    .Parameter contactSheetName
		"-ContactSheet_Intro_$skip.jpg" : contact sheet suffix 
    .Parameter updateOnly
		Only create images if contactsheet does not exist. Dont overwrite existing files, i.e. update mode
    .Parameter skip
		0: number of seconds to skip in before imaging starts
        (new-timespan -Minutes 23 -Seconds 30).TotalSeconds
    .INPUTS
        None. You cannot pipe objects to Create-Thumnails.
    .OUTPUTS
        None.
    .Notes
        NAME: Set-FolderImage
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:should not refrence .jpg
    .Link
        Http://www.ostat.com

#>
   	Write-Host("$($MyInvocation.MyCommand.Name) v$Version [VideoPath $VideoPath, Skip $skip]")
   
    # Verify we can access Mtu.EXE .
	if ([string]::IsNullOrEmpty($MtuPath) -or (Test-Path -LiteralPath $MtuPath) -ne $true)
	{
	    Write-Error "Mtu.exe path does not exist '$MtuPath'."
        return
    }
	
    if ([string]::IsNullOrEmpty($videoPath) -or (test-path -LiteralPath $videoPath) -eq $False) 
    {
        Log_Message "ERROR | File does not exist: $VideoPath. Exiting"
        return
    }

    # Verify we can access Mtu.EXE .
	if ([string]::IsNullOrEmpty($contactSheetName))
	{
        if($skip -eq 0)
        {
	        $contactSheetName = "-ContactSheet.jpg"
        }
        else
        {
            $contactSheetName = "-ContactSheet_$skip.jpg"
        }
    }

    $W = ''
    if($updateOnly)
    {
        $W = '-W'
    }

    $C = ''
    if($maximumSpaceBetween -gt 0)
    {
        $C = "-C $maximumSpaceBetween"
    }

    
	$video = Get-Item -LiteralPath $videoPath
    $ThumbFolder = join-path -path $video.Directory -childpath "thumbs"
    
	&$MTUPath -b 0.95 -B $skip -D $edgeDetection -P $C -r $rows -c 2 -w 0 $W -I -o $contactSheetName -O $ThumbFolder $videoPath | Out-String
}


function Resize-Image([string]$source, [string]$destination, [int]$size)
{
	## NOTE: Destination must end in .bmp, .gif, .png, .wmp, .jpeg or .tiff
	Add-Type -Assembly PresentationCore

	## Open and resize the image
	$image = New-Object System.Windows.Media.Imaging.TransformedBitmap (New-Object System.Windows.Media.Imaging.BitmapImage $source),
	                                                                   (New-Object System.Windows.Media.ScaleTransform $scale,$scale)
	## Write out an image file:
	$stream = [System.IO.File]::Open($destination, "OpenOrCreate")
	$encoder = New-Object System.Windows.Media.Imaging.$([IO.Path]::GetExtension($destination).substring(1))BitmapEncoder
	$encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($image))
	$encoder.Save($stream)
	$stream.Dispose()
}

function Create-ThumbnailsForChildFolders([string]$FolderPath) 
{
<#
    .Synopsis
        Create folder images for all child folders recursive that contain a video file
    .Description
    .Example
    .Parameter FolderPath
    .INPUTS
        None. You cannot pipe objects to Create-ThumbnailsForChildFolders.
    .OUTPUTS
        None.
    .Notes
        NAME:  Create-ThumbnailsForChildFolders
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:should not refrence .jpg
    .Link
        Http://www.ostat.com

#>
   	Write-Host("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")
   
    if ((test-path -LiteralPath $FolderPath) -eq $False) 
    {
        Log_Message "ERROR | Folder does not exist: $FolderPath. Exiting"
        return
    } 

    Get-ChildItem -LiteralPath $FolderPath -Recurse | Where {$_.psIsContainer -eq $true} | ForEach-Object { 
        #skip know helper folders
        if ($_.Name -ne "logs" -and $_.Name -ne "trash" -and $_.Name -ne "sample" -and $_.Name -ne "subtitles" -and $_.Name -ne "thumbs" )
        { 
            $ChildFolder = $_
            
            #confirm child folder contains a video file
            if (@(Get-ChildItem -literalpath $ChildFolder.fullname | where{$_.name -match $VideoFilesPattern}).count -gt 0)
            {
                Create-Thumbnails $ChildFolder.fullname
            }
        }
    } 
}


function Create-FolderImage([string]$FolderPath) 
{ Create-Thumbnails $FolderPath }

function Create-FolderImageForChildFolders([string]$FolderPath) 
{ Create-ThumbnailsForChildFolders $FolderPath }


# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmXTwe1aGYuepnnt2aq1A534P
# V+WgggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FNBiqiCPpYM4mUrFNCzVeT68YmYPMA0GCSqGSIb3DQEBAQUABIGAIYzNVwbuMGM9
# Sq7WQCuhB/rMeERPsXwkbZIuN4Mqg4pkEeNV6+FJos0+qNlSV19/L2LkvYg5iYNd
# NuupwoyedqLp7TXs0hkZOPuLzD2kGo2WgmCK6cthWwBtdHutFqrLcHZFsxS4Joz6
# d1tBBurfOHccpx7PL9o6S6+RfUDmX98=
# SIG # End signature block
