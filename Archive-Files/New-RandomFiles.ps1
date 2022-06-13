<#
    .SYNOPSIS
    Creates randomly generated files. Files are named 'GUID.txt', file content is also GUID based.

    .PARAMETER Path
    Path to folder where the files should be created.

    .PARAMETER FilesCount
    Number of files to be created.

    .PARAMETER GuidsPerFile
    Number of GUIDs to be added to each file.

    .PARAMETER DayRange
    range of days for the created date.

    .INPUTS
    None. You cannot pipe objects to Add-Extension.

    .EXAMPLE
    PS> .\New-RandomFiles.ps1 -Path 'D:\test\' -FilesCount 10000 -DayRange @(1..10000)
    Create 10000 random files in folder D:\test\ with a create data between 1 and 10000 days ago.
#>

param(
    [string]$Path = $PSScriptRoot,
    [int]$FilesCount = 1000,
    [int]$GuidsPerFile = 1000,
    [array]$DayRange = 1..356
)

function CreateRandomFile([string] $folder, [int] $guids, [Array] $days) 
{
    $sb = New-Object -TypeName "System.Text.StringBuilder"
    foreach($i in 1..$guids)
    {
        [void]$sb.AppendLine("$i - $([guid]::NewGuid())")
    }
  
    $path = (Join-Path $folder "$([guid]::NewGuid()).txt")
    $sb.ToString() | Out-File -FilePath $path 
    $ofset = (Get-Date).AddDays(-(Get-Random -InputObject $days))

    $item = Get-Item -Path $path
    $item.CreationTime = $ofset 
    $item.LastAccessTime = $ofset 
    $item.LastWriteTime = $ofset 
}

For ($i=1; $i -le $filesCount; $i++) {
    CreateRandomFile $Path $GuidsPerFile $DayRange
}
