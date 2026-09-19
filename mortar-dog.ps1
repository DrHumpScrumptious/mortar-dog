[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$Mortar,
    [Parameter(Mandatory = $false)]
    [string[]]$Target,
    [switch]$SetMortarSite,
    [switch]$ResetData
)
<# TODO:
Params for Verbosity
Usage func
min/max distance error
function to store mortar site in JSON for later
function to "clean" json
#>

<#####################################
VARS
######################################>
$_JSON_PATH = Join-Path $PSScriptRoot "data.json"
$_MIN_RANGE = 200
$_MAX_RANGE = 700

<#####################################
FUNCTIONS
######################################>
function Test-Success{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [bool]$Result,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$ErrMsg
    )

    if ($Result){
        Write-Host "SUCCESS" -ForegroundColor Green
    }
    else{
        Write-Host "FAIL" -ForegroundColor Red
        Write-Host "Error: $ErrMsg" -ForegroundColor Yellow
        exit
    }
}
function Get-MortarJSON{
    if (! (Test-Path $_JSON_PATH)){
        Write-Host "=== No JSON Data detected, creating template..." -NoNewline
        $template = @'
        {
            "MortarX": 0,
            "MortarY": 0
        }
'@
        $template | Set-Content -Path $_JSON_PATH -Encoding UTF8
        Test-Success $? "Failed to create JSON file"
    }
    Write-Host "=== Loading JSON data...." -NoNewline
    $_DATA = Get-Content -Path $_JSON_PATH -Raw | ConvertFrom-Json
    Test-Success $? "Failed to Load JSON"
    return $_DATA
}

function ConvertFrom-GameCoords{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [array]$GameCoords
    )

    [double]$xString = ($GameCoords.split(",")[0]).split("x")[1]
    [double]$yString = ($GameCoords.split(",")[1]).split("y")[1]

    return @($xString,$yString)
}

function Update-MortarCoords{
    [CmdletBinding()]
    param(
        [object]$DataFile,
        [double]$X_Cord,
        [double]$Y_Cord
        )

    Write-Host "=== Updating MortarSite X Coordinates..." -NoNewline
    $DataFile.MortarX = $X_Cord
    Test-Success $? "Failed to Update X Coordinates"

    Write-Host "=== Updating MortarSite Y Coordinates..." -NoNewline
    $DataFile.MortarY = $Y_Cord
    Test-Success $? "Failed to Update Y Coordinates"

    Write-Host "=== Writing data to $($_JSON_PATH)..." -NoNewline
    $DataFile | ConvertTo-JSON | Set-Content -Path $_JSON_PATH -Encoding UTF8
    Test-Success $? "Failed to Update JSON Path at $($_JSON_PATH)"
}

function Get-Range{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [double]$MortarX,
        [Parameter(Position = 1, Mandatory = $true)]
        [double]$MortarY,
        [Parameter(Position = 2, Mandatory = $true)]
        [double]$TargetX,
        [Parameter(Position = 3, Mandatory = $true)]
        [double]$TargetY
    )
    [double]$xABS = $("{0:F2}" -f $([System.Math]::Abs($MortarX-$TargetX)))
    [double]$yABS = $("{0:F2}" -f $([System.Math]::Abs($MortarY-$TargetY)))
    [double]$xPOW2 = [System.Math]::Pow($xABS,2)
    [double]$yPOW2 = [System.Math]::Pow($yABS,2)
    
    $range = $("{0:F2}" -f ([System.Math]::Sqrt(($xPOW2 + $yPOW2))*100))

    if ($range -gt $_MAX_RANGE){
        Write-Host "=== TARGET IS TOO FAR" -ForegroundColor Red
        exit
    }

    if ($range -lt $_MIN_RANGE){
        Write-Host "=== TARGET IS TOO CLOSE" -ForegroundColor Red
        exit
    }

    return $range
}

<#####################################
MAIN
######################################>

if($ResetData){
    if(! (Test-Path $_JSON_PATH)){
        Write-Host "=== No JSON File to Remove...ignoring"
    }
    else{
        Write-Host "=== Cleaning JSON Data file..." -NoNewline
        Remove-Item $_JSON_PATH
        Test-Success $? "Failed to delete JSON Data"
    }
}

$_MortarObj = Get-MortarJSON

if($PSBoundParameters.ContainsKey('Mortar')){
    [double[]]$MortarCoords = ConvertFrom-GameCoords $Mortar
    Write-Host "Mortar Site: x$($MortarCoords[0]), y$($MortarCoords[1])"
}
else
{
    [double[]]$MortarCoords = @($_MortarObj.MortarX, $_MortarObj.MortarY)
    Write-Host "Mortar Site: x$($MortarCoords[0]), y$($MortarCoords[1])"
}

if($SetMortarSite){
    Update-MortarCoords $_MortarObj $MortarCoords[0] $MortarCoords[1]
}


if($PSBoundParameters.ContainsKey('Target')){
    [double[]]$TargetCoords = ConvertFrom-GameCoords $Target
    Write-Host "Target Site: x$($TargetCoords[0]), y$($TargetCoords[1])"

    Get-Range $MortarCoords[0] $MortarCoords[1] $TargetCoords[0] $TargetCoords[1]
}
