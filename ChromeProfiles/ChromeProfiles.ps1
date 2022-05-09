# Powershell script to create Profiles in Google Chrome.
#  
# Useful for Software projects where you have multiple personas and you would like a fast and consistent way to create the profiles when onboarding people.
#  
# Features:
# Creates persona if it does not exist.
# Updates existing personal if it already exists.
# Persona folders are named to make it easy to identify them in the file system. Folders can be deleted if you no longer need the personas.
# 
# For each persona you can set:
#      Bookmark list
#      Theme colour
#      Profile Icon
#           Chrome supports 55 different icons, chrome://theme/IDR_PROFILE_AVATAR_1 -> chrome://theme/IDR_PROFILE_AVATAR_55. You can put them in to you browser to see what they look like.
# 
# Execution:
# Before running you need to close chrome. The profile settings changes would be lost otherwise.
# When you run the script, if the profile does not exist it will open chrome to create the profile. You need to close Chrome for the script to continue.
# If for some reason it gets messed up, go to your Chrome User Data folder and delete the impacted profiles, they will be called 'Profile-<profilename>


########################################
# Functions
########################################
$ErrorActionPreference = "Stop"

$bookmarkTemplate = @"
{
   "checksum": "de860e456a2777a737153e98fe21cf68",
   "roots": {
      "bookmark_bar": {
         "children": [ ],
         "date_added": "13239079236951894",
         "date_modified": "13239079241347919",
         "guid": "00000000-0000-4000-a000-000000000002",
         "id": "1",
         "name": "Bookmarks bar",
         "type": "folder"
      },
      "other": {
         "children": [  ],
         "date_added": "13239079236951910",
         "date_modified": "0",
         "guid": "00000000-0000-4000-a000-000000000003",
         "id": "2",
         "name": "Other bookmarks",
         "type": "folder"
      },
      "synced": {
         "children": [  ],
         "date_added": "13239079236951913",
         "date_modified": "0",
         "guid": "00000000-0000-4000-a000-000000000004",
         "id": "3",
         "name": "Mobile bookmarks",
         "type": "folder"
      }
   },
   "version": 1
}
"@

function Add-NoteProperty {
    #Add-NoteProperty -InputObject $obj -Property "prop3.nestedprop31.nestedprop311" -Value "somevalue"
    #https://stackoverflow.com/questions/48196089/add-nested-properties-to-a-powershell-object
    param(
        $InputObject,
        $Property,
        $Value,
        [switch]$Force
    )
    process {
        [array]$path = $Property -split "\."
        If ($Path.Count -gt 1) {
            #go in to recursive mode
            $Obj = New-Object PSCustomObject
            Add-NoteProperty -InputObject $Obj -Property ($path[1..($path.count - 1)] -join ".") -Value $Value
        }
        else {
            #last node
            $Obj = $Value
        }
        $InputObject | Add-Member NoteProperty -Name $path[0] -Value $Obj -Force:$Force
    }
}

function makeprofile($chromePath, $ProfileName, $icon, $links, $themeColour)
{
    Write-host "`r`nProcessing profile $($ProfileName)" -ForegroundColor Green
    $profileSystemName = "`Profile-$($ProfileName.Replace(' ', ''))";
    $profilePath = (Join-Path $chromeUserPath $profileSystemName)

    if(!(Test-Path $profilePath ))
    {
        Write-host "creating profile $($ProfileName)"
        Write-host "waiting for you to close chrome" -ForegroundColor Yellow
        & $chromePath --args --profile-directory="$profileSystemName" --no-first-run | Out-Null
        Write-host "detected Chrome Closed"    
    }
    else
    {
        Write-Host "Profile already exists '$($profilePath)'"
    }
    
    Write-host "updating chromeSettings"
    if(Test-Path $chromeSettingsFile)
    {
        Write-Verbose "opening chromeSettings '$($chromeSettingsFile)'"
        $content = Get-Content -Path $chromeSettingsFile  
        $match = $content | Select-String -Pattern "`"$($profileSystemName)`":{(.*?)}"
        $record = $match.Matches.Groups[1].Value 
        $record = $record -replace '"name":"(.*?)"',"`"name`":`"$($ProfileName)`""
        $record = $record -replace '"shortcut_name":"(.*?)"',"`"shortcut_name`":`"$($ProfileName)`""
        $record = $record -replace '"avatar_icon":"(.*?)"',"`"avatar_icon`":`"$icon`"" 
        $content = $content -replace "`"$($profileSystemName)`":{(.*?)}","`"$($profileSystemName)`":{$($record)}" 
        $content | set-content $chromeSettingsFile     
    }
    else
    {
        Write-Warning "Could not access '$($chromeSettingsFile)'"
    }
    
    Write-host 'updating profile bookmarks'
    $bookmarksPath = (Join-Path $profilePath 'Bookmarks')
    if(Test-Path $bookmarksPath)
    {
        $bookmarkDestination = "$($bookmarksPath)_backup_$(Date -Format 'yyyyMMddhhmmss')"
        Write-Verbose "backing up bookmarks '$($bookmarkDestination)'"
        Copy-Item -Path $bookmarksPath -Destination $bookmarkDestination
        $bookmarksJson = Get-Content $bookmarksPath -raw | ConvertFrom-Json
    }
    else
    {
        $bookmarksJson = $bookmarkTemplate | ConvertFrom-Json
    }

    Write-Verbose "opening chromeSettings '$($bookmarkTemplate)'"
    #TODO update existing link is not working.
    $bookmarksJson = $bookmarkTemplate | ConvertFrom-Json
    
    #"name": "New Tab",
    #"type": "url",
    #"url": "chrome://newtab/"
    $links.Keys | ForEach-Object {
        $linkKey = $_
        
        $bookmark = @($bookmarksJson.roots.bookmark_bar.children | Where-Object ($_.url -eq $links[$linkKey]['url']))[0]
        if($bookmark -eq $null)
        {
            $bookmark = New-Object PSCustomObject
            $bookmark | Add-Member -Type NoteProperty -Name 'name'-Value $links[$linkKey]['name']
            $bookmark | Add-Member -Type NoteProperty -Name 'type'-Value 'url'
            $bookmark | Add-Member -Type NoteProperty -Name 'url'-Value $links[$linkKey]['url']
            $bookmarksJson.roots.bookmark_bar.children += $bookmark
        }
        else
        {
             $bookmark.name = $links[$linkKey]['name']
             $bookmark.type = 'url'
             $bookmark.url = $links[$linkKey]['url']
        }
    }
    
    $bookmarksJson | ConvertTo-Json -Depth 100 | Out-File $bookmarksPath -Encoding utf8
          
    Write-host 'updating profile Preferences'
    $profilePrefrencesPath = (Join-Path $profilePath 'Preferences')
    if(Test-Path $profilePrefrencesPath)
    {
         Copy-Item -Path $profilePrefrencesPath -Destination "$($profilePrefrencesPath)_backup_$(Date -Format 'yyyyMMddhhmmss')"
         Write-Verbose "Opening '$($profilePrefrencesPath)'"
 
         $json = Get-Content $profilePrefrencesPath -raw | ConvertFrom-Json
         #"autogenerated":{"theme":{"color":-4776932}},"bookmark_bar":{"show_on_all_tabs":true},"bookmark_editor":{"expanded_nodes":[]}
         if($json.autogenerated -eq $null){
            $json | Add-Member -Type NoteProperty -Name 'autogenerated'-Value (New-Object PSCustomObject)
         }
         if($json.autogenerated.theme -eq $null){
            $json.autogenerated | Add-Member -Type NoteProperty -Name 'theme'-Value (New-Object PSCustomObject)
         }
         if($json.autogenerated.theme.color -eq $null){
            $json.autogenerated.theme | Add-Member -Type NoteProperty -Name 'color' -Value $themeColour
         }
         $json.autogenerated.theme.color = $themeColour


         #"extensions":{"theme":{"id":"autogenerated_theme_id"}}
         if($json.extensions.theme -eq $null){
            $json.extensions | Add-Member -Type NoteProperty -Name 'theme'-Value (New-Object PSCustomObject)
         }
         if($json.extensions.theme.id -eq $null){
            $json.extensions.theme | Add-Member -Type NoteProperty -Name 'id'-Value 'autogenerated_theme_id'
         }
           $json.extensions.theme.id = 'autogenerated_theme_id'

         $json | ConvertTo-Json -Depth 100 | Out-File $profilePrefrencesPath -Encoding utf8
    }
    else
    {
        Write-Warning "Could not access '$($profilePrefrencesPath)'"
    }
}

function BackUpChromeSettings([string]$chromeSettingsFile)
{
    #backup profile
    Copy-Item -Path $chromeSettingsFile -Destination "$($chromeSettingsFile)_backup_$(Date -Format 'yyyyMMddhhmmss')"
}

function CheckIfChomeIsRunning()
{
    if(Get-Process | ? {$_.ProcessName -like "*Chrome*"}){
        throw "Chrome is runnig, please close first"
    }
}

function CheckSettings($chromePath, $chromeUserPath)
{
    if(!(Test-Path -LiteralPath $chromePath)){
        throw "Path to Chrome.exe does not exist path:$($chromePath)"
    }
    if(!(Test-Path -LiteralPath $chromeUserPath)){
        throw "Path to chrome User data does not exist path:$($chromeUserPath)"
    }
}

########################################
# Settings
########################################
$chromePath = (Join-Path $env:LOCALAPPDATA "\Google\Chrome\Application\chrome.exe")

$chromeUserPath = (Join-Path $env:LOCALAPPDATA "\Google\Chrome\User Data")
$chromeSettingsFile = (Join-Path $chromeUserPath 'Local State')

########################################
# Profile settings and execution.
########################################

CheckIfChomeIsRunning
CheckSettings -chromePath $chromePath -chromeUserPath $chromeUserPath
BackUpChromeSettings -chromeSettingsFile $chromeSettingsFile

#example colours
$ColourGrey = -13154481
$ColourBlack = -16777216
$ColourLightOrange = -21696
$ColourLightPink = -20803
$ColourLightBlue = -10644508
$ColourLightTeal = -15098455
$ColourLightGreen = -12345273
$ColourDarkRed = -4776932 
$ColourDarkPink = -4385188 
$ColourDarkGreen = -13730510
$ColourDarkBlue = -15374912 
$ColourDarkTeal = -16748936

$devLinks = [Ordered]@{ 
    0 = @{name="env1"; url="https://env1.example.com"}; 
    1 = @{name="env2"; url="https://env2.example.com"}; 
    2 = @{name="env2"; url="https://env3.example.com"}; 
}

makeprofile $chromePath "profile1" "chrome://theme/IDR_PROFILE_AVATAR_20" $devLinks $ColourLightBlue
makeprofile $chromePath "profile2" "chrome://theme/IDR_PROFILE_AVATAR_21" $devLinks $ColourLightBlue
makeprofile $chromePath "profile3" "chrome://theme/IDR_PROFILE_AVATAR_22" $devLinks $ColourLightBlue
makeprofile $chromePath "profile4" "chrome://theme/IDR_PROFILE_AVATAR_23" $devLinks $ColourLightBlue

$prodLinks = [Ordered]@{ 
    0 = @{name="uat";  url="https://uat.example.com"}; 
    1 = @{name="prod"; url="https://prod.example.com"}; 
    2 = @{name="dr";   url="https://dr.example.com"}; 
}
makeprofile $chromePath "prod profile1" "chrome://theme/IDR_PROFILE_AVATAR_24" $prodLinks $ColourDarkRed
makeprofile $chromePath "prod profile2" "chrome://theme/IDR_PROFILE_AVATAR_25" $prodLinks $ColourDarkRed