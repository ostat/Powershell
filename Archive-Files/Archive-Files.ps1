<#
    .SYNOPSIS
    Batch archive files in a folder. Files are grouped by the created date.
    Batches can be monthly or weekly (Sunday to Saturday).
    Expected to be run regularly on folders containing a very large number of files.

    Files in the target folder are first considered for archiving and grouped by the target archive.
    Files are then written to the archives desired period archive.

    Performance considerations:
    Only scan the source folder once, this can still be quite slow for a large number of files.
    Each archive should only be opened once.

    .PARAMETER SourcePath
    Path to folder containing files to archive.

    .PARAMETER ArchiveLocation
    Location to store the archived files.

    .PARAMETER DeleteArchivedFiles
    If true files that are archived will be deleted.

    .PARAMETER AgePeriods
    Number of periods before a file should be archived.

    .PARAMETER PeriodType
    Options are 'Monthly' or 'Weekly', 'Monthly' is default.

    .INPUTS
    None. You cannot pipe objects to Add-Extension.

    .EXAMPLE
    PS> .\Archive-Files.ps1 -SourcePath 'C:\logs\'
    Archive the files in the folder Run 'C:\logs\'.
#>

param(
    [string]$SourcePath = $PSScriptRoot,
    [string]$ArchiveLocation = 'archive',
    [bool]$DeleteArchivedFiles = $true,
    [ValidateSet('monthly','weekly')] 
    [string]$PeriodType = 'monthly',
    [int]$AgePeriods = 12
)

#########################################################
# Setup
#########################################################

$Script:Version      = '0.1'

Add-Type -AssemblyName System.IO.Compression 
Add-Type -AssemblyName System.IO.Compression.FileSystem

#Contains list of target archives and files that need to be added to them.
$batchArchives = New-Object 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[string]]'
 
#Error handling 
$ErrorActionPreference = "Stop"
trap
{
    $Script = $_.InvocationInfo.ScriptName
    $Line = $_.InvocationInfo.ScriptLineNumber
    $Offset = $_.InvocationInfo.OffsetInLine
    $ErrorMsg = $_.ToString()
    $Msg = "Error occurred in $Script at Line $Line Offset $Offset `nException Message: $ErrorMsg"
   
    Write-Host "$(Get-Date -format 'yyyy-MM-dd_HH:mm:ss.ffff')"
    Write-Host $Msg
    throw $_
    # Report the failure to the caller - just in case...
    exit 1
}

#########################################################
# Functions
#########################################################
function Write-ScriptExecutionInfo($Invocation) {
    Write-Host "$(Get-Date -format 'yyyy-MM-dd_HH:mm:ss.ffff') Starting Invocation $($Invocation.InvocationName)"
    Write-Host "ScriptVersion: $script:Version"
   
    Write-Host "LocationPath: $((Get-Location).Path)"
    Write-Host "PowerShell $($Host.Version) $(if ([System.IntPtr]::Size -eq 4) { "32-bit" } else { "64-bit" }) - syswow64: $(if (([diagnostics.process]::GetCurrentProcess()).path -match '\\syswow64\\') { "true" } else { "false" })"
    Write-Host "User $($env:username) $(if ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) { "Elevated" } else { "Not Elevated" })" 
   
    Write-Host 'Passed in parameters:'
    foreach($ps in $Invocation.BoundParameters.GetEnumerator())
    {
        Write-Host "`t$($ps.Key):'$($ps.Value)'"
    }
}

function New-DirectoryIfNeeded([String] $path)
{
    If(!(test-path $path))
    {
        Write-host "Creating folder '$path'"
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }
}

<#
    Consider a file for archiving. 
    Files will grouped for later archiving.
#>
function Group-FileForArchive(
    [Parameter(Mandatory=$true)]
    [System.IO.FileInfo] $TargetItem,
    [String] $ArchiveLocation,
    [String] $ArchiveNameBase,
    [String] $RootFolder,
    [ValidateSet('monthly','weekly')] 
    [String] $PeriodType,
    [DateTime]$MaxAge
)
{
    $itemDate = $TargetItem.LastWriteTime
    $filePath = $TargetItem.FullName
    if($itemDate -ge $maxAge)
    {
        return
    }
    Write-Verbose "Archiving file '$filePath' age $($itemDate.toString('yyyy-MM-dd.hh:mm'))"
    
    switch ($PeriodType.ToLower())
    {
        'weekly' {
            $ArchiveMinLimit = Get-Date($itemDate.AddDays(-($itemDate.DayOfWeek.value__))).Date
            $ArchiveMaxLimit = Get-Date($ArchiveMinLimit.AddDays(7))
        }
        'monthly' {
            $ArchiveMinLimit = Get-Date ($itemDate).Date -day 1
            $ArchiveMaxLimit = Get-Date ($ArchiveMinLimit).AddMonths(1).AddDays(-1)
        }
    }
   
    $targetArchive = (Join-Path $ArchiveLocation "$($ArchiveNameBase)_$($ArchiveMinLimit.toString('yyyyMMdd'))-$($ArchiveMaxLimit.toString('yyyyMMdd')).zip")
 
    Write-Verbose "Archiving files older $($maxAge.toString('yyyy-MM-dd.hh:mm')) to file:'$targetArchive'"
   
    #Create batch
    if(!($batchArchives.Keys.Contains($targetArchive)))
    {
        $batchArchives.Add($targetArchive, (New-Object System.Collections.Generic.List[string]))
    }
 
    #Add file to batch
    $batch = $batchArchives[$targetArchive]
    $batch.add($filePath)
}

function Compress-FilesSelectedForArchive(
    [bool]$removeArchivedFiles
)
{
    $batchArchives.Keys | ForEach-Object {
        $archivePath = $_
        $filesForArchive = $batchArchives[$archivePath]
        
        $CompressionLevel    = [System.IO.Compression.CompressionLevel]::Optimal
        if(Test-Path -LiteralPath $archivePath)
        {  
            $Mode = [System.IO.Compression.ZipArchiveMode]::Update
        }
        else
        {
            $Mode = [System.IO.Compression.ZipArchiveMode]::Create 
        }
        Write-Host "$($Mode) Archive path:'$($archivePath)' Files:'$($filesForArchive.Count)'"
 
        $fileExecutionTime = Measure-Command {
            $zip = [System.IO.Compression.ZipFile]::Open($archivePath, $Mode)
 
            $filesForArchive = $batchArchives[$archivePath]
 
            $filesForArchive | ForEach-Object {
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_, (Split-Path $_ -leaf), $CompressionLevel) | out-null
            }
 
            # Dispose of the object when we are done
            $zip.Dispose();
        }
        Write-Host "Archive File created. ExecutionTime:$fileExecutionTime"
 
        if($removeArchivedFiles){
            $filesForArchive | ForEach-Object {
                Remove-Item $_
            }
        }
    }
}
 
function Archive-FilesInFolder(
    [String] $folderPath,
    [String] $archiveLocation,
    [ValidateSet('monthly','weekly')] 
    [String] $periodType,
    [int]$agePeriods,
    [bool]$removeArchivedFiles
)
{
    $totalExecutionTime = Measure-Command {
        $now = (get-date).Date
       
        #Calculate the max age to be considered for archiving.
        switch ($periodType.ToLower())
        {
            'weekly' {
                $maxAge = Get-Date ($now.AddDays(-($agePeriods *7 )).AddDays(-($now.DayOfWeek.value__))) 
            }
            'monthly' {
                $maxAge = Get-Date ($now.AddMonths(-$agePeriods)) -day 1
            }
        }
 
        Write-Verbose "Batching files in folder '$folderPath' older than age $($maxAge.toString('yyyy-MM-dd.hh:mm'))"
        $uri = new-object System.Uri($folderPath);
        if($uri.IsUnc)
        {
            $archiveNameBase = "$($uri.Host)_$(Split-Path $folderPath -leaf)"
        }
        else
        {
            $archiveNameBase = "$($env:computername)_$(Split-Path $folderPath -leaf)"
        }

        $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
        $fileCounter = 0
        $batchExecutionTime = Measure-Command {
            #Consider all files in the source folder for archiving.
            Get-ChildItem -Path $folderPath -File -Recurse | Where-Object {!($_.FullName.Contains($archiveLocation))} | ForEach-Object {
                $fileCounter = $fileCounter + 1
                if($fileCounter % 100000 -eq 0){
                    #Progress logging
                    Write-Host "$(Get-Date) Batching files for archive, batchCount:$fileCounter ElapsedTime:$($stopwatch.Elapsed)"
                }
 
                Group-FileForArchive -TargetItem $_ -RootFolder $folderPath -ArchiveNameBase $archiveNameBase -ArchiveLocation $archiveLocation -PeriodType $periodType -MaxAge $maxAge
            } 
        }
        Write-Host "File batching completed files:'$($fileCounter)' ExecutionTime:$batchExecutionTime"
 
        $archiveExecutionTime = Measure-Command {
            Compress-FilesSelectedForArchive -removeArchivedFiles $removeArchivedFiles
        }
        Write-Host "Archiving completed ExecutionTime:$archiveExecutionTime"
    }
 
    Write-Host "Total execution time for $totalExecutionTime"
    Write-Host "Files total files considered fileCounter:'$($fileCounter)'"
}
 
#########################################################
# Main Execution
#########################################################
 
Write-ScriptExecutionInfo -Invocation (Get-Variable MyInvocation).Value
Write-host "Archive Target:$($SourchPath) periodType:$($PeriodType) agePeriods:$($AgePeriods)"

if($SourchPath -ne "")
{
    if ((Test-Path -LiteralPath $SourchPath) -eq $false) {
        Write-Warning "Unable to access source location $SourchPath"
        continue
    }

    $archivePath = Join-Path $SourchPath  $ArchiveLocation
    New-DirectoryIfNeeded $archivePath

    if ((Test-Path -LiteralPath $archivePath) -eq $false) {
        Write-Warning "Unable to access archive location '$archivePath'"
        continue
    }

    Archive-FilesInFolder -folderPath $SourcePath -archiveLocation $archivePath `
                            -periodType $PeriodType -agePeriods $AgePeriods `
                            -removeArchivedFiles $DeleteArchivedFiles
}
