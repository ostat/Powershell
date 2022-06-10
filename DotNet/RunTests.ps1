<#
    .SYNOPSIS
    Run test for all projects by command line and display summary results

    Uses https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-test

    .PARAMETER Path
    Root seach folder.

    .PARAMETER ProjectFilters
    Filters to select projects.

    .PARAMETER TestFilterExpression
    Expression for filtering tests.

    .INPUTS
    None. You cannot pipe objects to Add-Extension.

    .EXAMPLE
    PS> .\RunTests.ps1 -Path  'C:\src\project\' -TestFilterExpression 'TestCategory=unit'
    Run test under the given path with the report on given folder.
#>

param(
    [string]$Path = $PSScriptRoot,
    [string[]]$ProjectFilters = @('*tests.csproj', '*test.csproj'),
    [string]$TestFilterExpression = ''
)

$results = @()
$totaMeasure = Measure-Command {
    Get-Childitem -Path $Path -Include $ProjectFilters -File -Recurse | ForEach-Object {       
        Write-Host "Running $($_.BaseName) path:'$($_.FullName)'" -ForegroundColor Green

        #use dotnet exe to build and run tests
        $TestOutput = ""
        if($TestFilterExpression) {
            dotnet test $_.FullName --filter $TestFilterExpression | Tee-Object -Variable TestOutput | Out-Null
        }
        else{
            dotnet test $_.FullName | Tee-Object -Variable TestOutput | Out-Null
        }
      
        Write-Verbose -Message "$([string]::Join("`r`n", $TestOutput))"
    
        #Last line has a summary of results
        $lastLine = $TestOutput.Split([Environment]::NewLine) | Select -Last 1
        $reg = '^(?<result>\w*)!\s*-\s*Failed:\s*(?<failed>\d*),\s*Passed:\s*(?<passed>\d*),\s*Skipped:\s*(?<skipped>\d*),\s*Total:\s*(?<total>\d*),\s*Duration:\s*(?<duration>.*?)\s-\s(?<details>.*)$'
        $result = [regex]::Matches($lastLine, $reg)
      
        if($result.Success -eq $true)
        {
            Write-host $lastLine
            $results += [pscustomobject]@{
                Path=$_.FullName
                FolderName=$_.Directory.Name
                Result=$result[0].Groups['result'].Value
                Failed=$result[0].Groups['failed'].Value -as [int]
                Passed=$result[0].Groups['passed'].Value -as [int]
                Skipped=$result[0].Groups['skipped'].Value -as [int]
                Total=$result[0].Groups['total'].Value -as [int]
                Duration=$result[0].Groups['duration'].Value
                Details=$result[0].Groups['details'].Value
                output=$TestOutput}
        }
        else{
            #Most likley errored, last 5 linke will likley have the error
            $lastfiveLines = $TestOutput.Split([Environment]::NewLine) | Select -Last 5
            Write-Warning  "$([string]::Join("`r`n", $lastfiveLines))"
            $results += [pscustomobject]@{
                Path=$_.FullName
                FolderName=$_.Directory.Name
                Result=''
                Failed=''
                Passed=''
                Skipped=''
                Total=''
                Duration=''
                Details=''
                output=$TestOutput}
        }
    }
}

Write-Host "Finished $($totaMeasure.ToString())`r`n" -ForegroundColor Green

#Display formatted results for all test projects executed
$e = [char]27
$results  | Format-Table -Property FolderName, @{
    Label = "Result"
    Expression =
    {
        if([string]::IsNullOrEmpty($_.Result)){
            $_.Result = 'Unknown'
        }
    
        switch ($_.Result)
        {
            'Failed' { $color = '31'; break }
            'Passed' { $color = '92'; break }
            default { $color = '0'}
        }
        "$e[${color}m$($_.Result)${e}[0m"
    }}, @{
    Label = "Failed"
    Expression =
    {
        if($_.Failed -gt 0)
            { $color = '31'}
        else 
            { $color = '0' }
       "$e[${color}m$($_.Failed)${e}[0m"
    }}, @{
    Label = "Passed"
    Expression =
    {
        if($_.Passed -gt 0)
            { $color = '92'}
        else 
            { $color = '0' }
        "$e[${color}m$($_.Passed)${e}[0m"
    }}, @{
    Label = "Skipped"
    Expression =
    {
        if($_.Skipped -gt 0)
            { $color = '94'}
        else 
            { $color = '0' }
       "$e[${color}m$($_.Skipped)${e}[0m"
    }}, Total, @{n='Duration';e={$_.Duration};align='right'}