[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [double]$Mortar_X,
    [Parameter(Position = 1, Mandatory = $true)]
    [double]$Mortar_Y,
    [Parameter(Position = 2, Mandatory = $true)]
    [double]$Target_X,
    [Parameter(Position = 3, Mandatory = $true)]
    [double]$Target_Y
)
<# TODO:
Use JSON, create one from embedded template if none
Params for Verbosity
Usage func
min/max distance error
#>

<#####################################
VARS
######################################>


<#####################################
FUNCTIONS
######################################>


<#####################################
MAIN
######################################>
#Write-Host "=== Start"

[double]$xABS = $("{0:F2}" -f $([System.Math]::Abs($Target_X-$Mortar_X)))
#Write-Host "=== X Abs: $xABS"

[double]$yABS = $("{0:F2}" -f $([System.Math]::Abs($Target_Y-$Mortar_Y)))
#Write-Host "=== Y Abs: $yABS"

[double]$xPOW2 = [System.Math]::Pow($xABS,2)
#Write-Host "=== X Abs ^2: $xPOW2"

[double]$yPOW2 = [System.Math]::Pow($yABS,2)
#Write-Host "=== Y Abs ^2: $yPOW2"

Write-Host "=== SET RANGE TO: $("{0:F2}" -f ([System.Math]::Sqrt(($xPOW2 + $yPOW2))*100))"

#Write-Host "=== END"