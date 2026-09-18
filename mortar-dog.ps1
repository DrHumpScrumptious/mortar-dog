[CmdletBinding()]
param(
    
    [Parameter(Position = 0, Mandatory = $false)]
    [string[]]$Mortar
    <#
    [Parameter(Position = 2, Mandatory = $true)]
    [double]$Target_X,
    [Parameter(Position = 3, Mandatory = $true)]
    [double]$Target_Y
    #>
)
<# TODO:
convert ingame string to x and y values e.g. - x95.96, y109.39
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

function Get-AbsoluteValue{
    [double]$xABS = $("{0:F2}" -f $([System.Math]::Abs($Target_X-$Mortar_X)))
    #Write-Host "=== X Abs: $xABS"

    [double]$yABS = $("{0:F2}" -f $([System.Math]::Abs($Target_Y-$Mortar_Y)))
    #Write-Host "=== Y Abs: $yABS"
}

function Get-Pow2Value{
    [double]$xPOW2 = [System.Math]::Pow($xABS,2)
    #Write-Host "=== X Abs ^2: $xPOW2"

    [double]$yPOW2 = [System.Math]::Pow($yABS,2)
    #Write-Host "=== Y Abs ^2: $yPOW2"
}

<#####################################
MAIN
######################################>
#Write-Host "=== Start"

$_MortarObj = Get-MortarJSON

[double[]]$MortarCoords = ConvertFrom-GameCoords $Mortar

#Write-Host "=== SET RANGE TO: $("{0:F2}" -f ([System.Math]::Sqrt(($xPOW2 + $yPOW2))*100))"

#Write-Host "=== END"
