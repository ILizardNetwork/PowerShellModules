$moduleName = "LizardNetwork"
$configPath = $env:PSModulePath.Split([System.IO.Path]::PathSeparator)[0] + [System.IO.Path]::DirectorySeparatorChar + `
  $moduleName + [System.IO.Path]::DirectorySeparatorChar + "config.json"

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