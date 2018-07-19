<#

WorldJournal.Log.psm1

    2018-04-30 Initial creation
    2018-05-11 Port to PowerShell module
    2018-05-14 Add 'New-Log' function

About [New-Log]

'Date' can be set to specific date, or leave blank to use the current date/time.
If 'Date' value is defined by user then HHmmss value will be all zero, 
Using user defined date and yyyyMMdd-HHmmss format together is pointless.
'MakeSubFolder' default value is False.
Returns object with 'FullName' and 'Directory' properties.

#>


Function New-Log() {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $false)][ValidateSet('True', 'False')][String]$MakeSubFolder = 'False',
        [Parameter(Mandatory = $true)][ValidateSet("yyyyMMdd", "yyyyMMdd-HHmmss")][String]$LogFormat,
        [Parameter(Mandatory = $false)][ValidateSet("yyyyMMdd", "yyyyMMdd-HHmmss")][String]$SubFolderFormat = 'yyyyMMdd-HHmmss',
        [Parameter(Mandatory = $false)][string][ValidatePattern("\d{4}-\d{2}-\d{2}")]$Date = (Get-Date)
    )

    $getDate = Get-Date($Date)
    $baseName = (Get-Item $Path).BaseName
    $directoryName = (Get-Item $Path).DirectoryName

    $logRoot = $directoryName + "\_" + $baseName + "-Log\"
    if (!(Test-Path($logRoot))) {New-Item $logRoot -Type Directory | Out-Null}

    if ($MakeSubFolder -eq 'True') {
        $logPath = $logRoot + $getDate.ToString($SubFolderFormat) + "\"
        if (!(Test-Path($logPath))) {New-Item $logPath -Type Directory | Out-Null}
    }
    else {
        $logPath = $logRoot
    }

    $log = $logPath + $getDate.ToString($LogFormat) + ".txt"
    if (!(Test-Path($log))) {New-Item $log -Type File | Out-Null}

    $object = New-Object -TypeName psobject 
    $object | Add-Member -MemberType NoteProperty –Name FullName –Value $log
    $object | Add-Member -MemberType NoteProperty –Name Directory –Value $logPath
    Write-Output $object

}

Function Write-Log() {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Verb,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Noun,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][ValidateSet("Long", "Short")][String]$Type,
        [Parameter(Mandatory = $true)][ValidateSet("Normal", "Good", "Bad", "Warning", "System")][String]$Status,
        [Parameter(Mandatory = $false)][ValidateSet('String', 'Null')][String]$Output = 'Null'
    )

    switch ($Type) {
        Long { 
            if($Status -eq "Normal"){
                $msg = (Get-Date).ToString("HH:mm:ss") + " " + $Verb.ToUpper() + " " + $Noun
            }else{
                $msg = (Get-Date).ToString("HH:mm:ss") + " " + $Verb.ToUpper() + " " + $Noun + " [" + $Status + "]"
            }
            break 
        }
        Short { $msg = "* " + $Verb + " : " + $Noun; break }
    }

    switch ($Status) {
        Good    { $color = "Green"; break }
        Bad     { $color = "Red"; break }
        Warning { $color = "Yellow"; break }
        System  { $color = "Cyan"; break }
        Normal  { $color = (Get-Host).UI.RawUI.ForegroundColor; break } 
        default { $color = (Get-Host).ui.rawui.ForegroundColor; break } 
    }

    if ($color -eq -1) {
        Write-Host $msg
    }
    else {
        Write-Host $msg -ForegroundColor $color
    }

    $msg | Add-Content $Path

    if($Output -eq 'String'){
        return $msg
    }

}



Function Write-Line() {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Length,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $msg = ("-" * $Length)
    Write-Host $msg -ForegroundColor Cyan 
    $msg | Add-Content $Path

}