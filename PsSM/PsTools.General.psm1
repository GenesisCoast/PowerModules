function Write-DebugLog(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)][string] $Message = "`n",
    [Parameter(Mandatory = $false)][string] $LogFile = ".\$((Get-Date).ToString("yyyyMMdd")).log",
    [Parameter(Mandatory = $false)][switch] $NoInfo,
    [Parameter(Mandatory = $false)][switch] $Header,
    [Parameter(Mandatory = $false)][switch] $Vital,
    [Parameter(Mandatory = $false)][switch] $Warning,
    [Parameter(Mandatory = $false)][switch] $Error
) {
    function WriteMessage([string] $Msg, [ConsoleColor] $Color) {
        Out-File $LogFile -InputObject $Msg -Append
        Write-Host $Msg -ForegroundColor $Color
    }
    function GetTimeStamp() {
        return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    }
    function GetHeader() {
        return [string]::Concat((1..100 | ForEach-Object {"="}))
    }

    if ($Header) { WriteMessage "$(GetHeader)" -Color White }
    if ((-not $NoInfo) -and (-not $Header)) {
        if ($Warning)   { WriteMessage "$(GetTimeStamp)[WARNG]: $Message" -Color Yellow }
        elseif ($Error) { WriteMessage "$(GetTimeStamp)[ERROR]: $Message" -Color Red }
        elseif ($Vital) { WriteMessage "$(GetTimeStamp)[VITAL]: $Message" -Color Cyan }
        else            { WriteMessage "$(GetTimeStamp)[GENRL]: $Message" -Color White }
    }
    else {
        WriteMessage $Message -Color White
    }
    if ($Header) { WriteMessage "$(GetHeader)`n" -Color White }
}
