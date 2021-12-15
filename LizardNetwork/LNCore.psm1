$moduleName = "LizardNetwork"
$configPath = $env:PSModulePath.Split([System.IO.Path]::PathSeparator)[0] + [System.IO.Path]::DirectorySeparatorChar + `
  $moduleName + [System.IO.Path]::DirectorySeparatorChar + "config.json"

# Import the LizardNetwork config
function Import-LNJsonConfig {
  if (Test-Path $configPath) {
    $json = Get-Content $configPath -Raw
    return ($json | ConvertFrom-Json)
  }
}

# Gets either the parameter value or the default value.
# Prefers the ParameterValue. If it's empty, it will use the DefaultValue
function Get-LNDefaultOrParameterValue($DefaultValue, $ParameterValue) {
  if ($ParameterValue) {
    return $ParameterValue
  }

  return $DefaultValue
}

function Write-LNInfo($Text, $Format="dd.MM.yyyy - HH:mm:ss") {
  $Text = "[" + (Get-Date -Format $Format) + "] [INF]`t" + $Text
  Write-Highlighted -Color White -Text $Text
}

function Write-LNError($Text, $Format="dd.MM.yyyy - HH:mm:ss") {
  $Text = "[" + (Get-Date -Format $Format) + "] [ERR]`t" + $Text
  Write-Highlighted -Color Red -Text $Text
}

# Write to console
function Write-Highlighted([string]$Color, [string]$Text) {
  Write-Host $Text -ForegroundColor $Color
}