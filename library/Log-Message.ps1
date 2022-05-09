#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '1.0.0.4'
<#
Comments
    global logging
#>

function Log_Message([string]$Message) {
<#
    .Synopsis
        logs a message to psLog file
    .Example
        Log_Message "the message"
        Logs "the message to the log file
    .Description
        Logs a message to the global log file
        Global log file is usually inside the profile folder
        Writes content to both the file and the console so any transction logging will also get the message.
    .Parameter Message
        Message to be logged
    .Notes
        NAME: Log_Message
        AUTHOR: max
        LASTEDIT: 12/14/2010 19:30:08
        KEYWORDS:
    .Link
    Http://www.ostat.com
#>
  
    [datetime]$date = get-date
    [String]$filename = "$(join-path -path $GlobalLogPath -childpath 'PSLog-{0}.log')" -f $date.ToString( "yyyyMM")
        
    CreateDirectoryIfNeeded $GlobalLogPath
    
    add-content $filename $Message
    Write-Host $Message
}

function Prepaire-New-logFile([string]$logFolder, [string]$functionName) {
<#
    .Synopsis
        OLD FUNCTION NOW USE Create-TempLogFile     
    .Example
        Prepaire-New-logFile
    .Parameter 
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Prepaire-New-logFile
        AUTHOR: max
        LASTEDIT: 12/14/2010 20:53:20
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>

    #create folder if needed
    CreateDirectoryIfNeeded  $logFolder 
    
    #Confirm folder exists
    if ((test-path -LiteralPath $logFolder -pathtype container) -eq $False)
    {
        write-error "Was unable to create log folder: '$logFolder'"
    }
    else
    {
        #Move log file
        [datetime]$date = get-date
        [String]$newFilePath = "$(join-path -path $logFolder -childpath '{0}-{1}.log')" -f $functionName, $date.ToString( "yyyyMMddhhmmss")
       
        return [String]$newFilePath
    }
}

function Create-TempLogFile() {
<#
    .Synopsis
        Creates a new temp logfile in toe globallog 
        returns the file path
    .Example
        Create-TempLogFile
    .Parameter prefix
        Prefix of the file
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Create-TempLogFile
        AUTHOR: max
        LASTEDIT: 12/14/2010 20:53:20
        KEYWORDS:
        Dev: This function makes no sence, what is it for?
    .Link
        Http://www.ostat.com
#>
Param
    (
    [parameter(Position=0)] [string] $prefix="temp"
    )
        [String]$folder = join-path -path $GlobalLogPath -childpath "temp"
        
        CreateDirectoryIfNeeded $GlobalLogPath
        CreateDirectoryIfNeeded $folder
        
        NewTempFile $folder $prefix
        
        #add-content $filename $Message
        #Write-Host $Message
}

function Save-Logfile([string]$tempName, [string]$logFolder, [string]$functionName) 
{
<#
    .Synopsis
        moves a temp made log file to the target folder
        if folder is not foo\log\ add \log\, so \foo\ becomes foo\log\
    .Example
        Save-Logfile
    .Parameter prefix
        Prefix of the file
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Save-Logfile
        AUTHOR: max
        LASTEDIT: 12/14/2010 20:53:20
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version at: $(get-date)")
    
    if([string]::IsNullOrEmpty($tempName) -eq $true) {
        Write-error ("Saving Log failed: tempName passed in is null")
        return
    }
    if([string]::IsNullOrEmpty($logFolder) -eq $true) {
        Write-error ("Saving Log failed: logFolder passed in is null")
        return
    }
    if([string]::IsNullOrEmpty($functionName) -eq $true) {
        Write-error ("Saving Log failed: functionName passed in is null")
        return
    }
    if ((test-path -LiteralPath $tempName) -eq $True)
    {
        #refrence to source folder
        $LogFile = get-item -LiteralPath $tempName  
            
        #check if folder exists    
        CreateDirectoryIfNeeded  $logFolder 
        
        #Confirm folder exists
        if ((test-path -LiteralPath $logFolder -pathtype container) -eq $False)
        {
            write-error "Was unable to create log folder: '$logFolder'"
        }
        else
        {
            #Move log file
            [datetime]$DATE = get-date
            [String]$newFilename = "{0}-{1}.log" -f $functionName, $DATE.ToString( "yyyyMMddhhmmss")
            [String]$newFilePath = join-path -path $logFolder -childpath $newFilename
           
            write-verbose "moving logfile to item log folder"
            
            Move-Item -LiteralPath $LogFile.FullName $newFilePath -Force
            
            Log_Message("Created log $Filename")
        }
    }
}


function NewTempFile() {
<#
    .Synopsis
        Creates a temp file to store logging info in to
    .Description
        http://poshtips.com/2010/08/30/more-on-temporary-files/
        The resulting format is DirectoryPath\FilePrefix_YYYYMMDD-hhmmss-mmmm.FileType
        Where:
        
        YYYYMMDD = Year Month day (e.g. ?20100830?) August 30, 2010
        hhmmss = Hour Minute Second (e.g. ?100548?) 10:05:48 AM
        mmmm = Miliseconds (e.g. ?446721?)
        
        the .net way is [System.IO.Path]::GetTempFileName()
    .Example
    .Parameter prefix
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: NewTempFile
        AUTHOR: max
        LASTEDIT: 12/14/2010 20:53:20
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
Param
    (
    [parameter(Position=0)] [string] $folder="",
    [parameter(Position=1)] [string] $filePrefix="temp",
    [parameter(Position=2)] [string] $fileType="log"
    )
 
    #create the folder (if needed) if it does not already exist
    if ($folder -ne "") {
        if (!(test-path $folder)) {
            write-host "creating new folder `"$folder`"..." -back black -fore yellow
            new-item $folder -type directory | out-null
            }
        if (!($folder.endswith("\"))) {
            $folder += "\"
            }
        }
 
    #generate a unique file name (with path included)
    $x = get-date
    $TempFile=[string]::format("{0}_{1}{2:d2}{3:d2}-{4:d2}{5:d2}{6:d2}-{7:d4}.{8}",
        $filePrefix,
        $x.year,$x.month,$x.day,$x.hour,$x.minute,$x.second,$x.millisecond,
        $fileType)
    $TempFilePath=[string]::format("{0}{1}",$folder,$TempFile)
 
    #create the new file
    if (!(test-path $TempFilePath)) {
        new-item -path $TempFilePath -type file | out-null
        }
    else {
        throw "File `"$TempFilePath`" Already Exists!"
        }
 
return $TempFilePath
}
    

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUubpb3nMyS1gwiiqZ0wLLyI8q
# f5ygggI9MIICOTCCAaagAwIBAgIQvBf8+FZ1TpZGQZ4AtBXcMTAJBgUrDgMCHQUA
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
# FMZDBtYWh2xTnQxNL7iIzAsQ/GwGMA0GCSqGSIb3DQEBAQUABIGAmJRigehmlv4q
# CtWhXwqY/YDR1vDXlkgZW1wYRunGd+uyBce0umNsXHtLJTI9PpVZiX19Ru6yv+Na
# 76qSeNsVfsYJicZ3UoCu6jBgzyaKG0Mk89x0D3JXXinkLb1AGTHF4EdqKYG319uR
# VyjHs7JwSPwQLhB/GqmZBVgI6l+Y37s=
# SIG # End signature block
