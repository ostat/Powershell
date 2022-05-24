<#
    .SYNOPSIS
    Script reports projects with know known vulnerable packages

    .PARAMETER SourcePath
    Root seach folder all solutions in child folder will be reported on.

    .PARAMETER PackageFilter
    Filter the report of packages

    .INPUTS
    None. You cannot pipe objects to Add-Extension.

    .EXAMPLE
    PS> .\VulnerablePackages.ps1 -SourcePath 'c:\src\project'
#>
param(
    [string]$SourcePath = $PSScriptRoot
)

function CheckForVulnerablePackages
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath
    )

    Write-Host "Reading solution: '$SolutionPath'" -ForegroundColor Green

    $solutionItem = get-Item $SolutionPath
    Get-Content $SolutionPath | `
        where { $_ -match "Project.+, ""(.+.csproj)""," } | `
        foreach {
            $ConfigPath = Join-Path $solutionItem.Directory.FullName $matches[1]
            if(test-path -LiteralPath $ConfigPath)
            {
                $projectItem = Get-Item $ConfigPath
         
                dotnet list $projectItem.FullName package --vulnerable --include-transitive --source 'https://api.nuget.org/v3/index.json' | Tee-Object -Variable 'output' | Out-Null
                $output = [system.String]::Join("`r`n", $output)
                if(!$output.Contains('has no vulnerable packages'))
                {
                    Write-Warning "Project has vulnerable packages : '$ConfigPath'"
                    Write-Host $output
                }
            }
        }
}

Get-ChildItem -LiteralPath $SourcePath -recurse -Filter *.sln | foreach { CheckForVulnerablePackages $_.FullName }