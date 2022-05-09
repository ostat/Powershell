#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '1.0.0.1'
<#
Comments
    Common helper scripts
#>
 
function CreateDirectoryIfNeeded ( [string] $Directory ){
<#
    .Synopsis
        checks if a older exists, if it does not it is created
    .Example
        CreateDirectoryIfNeeded "c:\foobar"
        Creates folder foobar in c:\
    .Parameter 
        The parameter
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: CreateDirectoryIfNeeded
        AUTHOR: max
        LASTEDIT: 12/14/2010 20:53:20
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version : [Directory $directory]")

    if([string]::IsNullOrEmpty($directory) -eq $true) {
        Write-error ("Directory creation failed: path passed in is null")
    }
    
    if ((test-path -LiteralPath $directory) -ne $True)
    {
        New-Item $directory -type directory | out-null
        
        if ((test-path -LiteralPath $directory) -ne $True)
        {
            Write-error ("Directory creation failed: '$directory'")
            return #[boolean]$false
        }
        else
        {
            Write-verbose ("Creation of directory succeeded")
            return #[boolean]$true
        }
    }
    else
    {
        Write-verbose ("Creation of directory not needed")
        return #[boolean]$true
    }
}