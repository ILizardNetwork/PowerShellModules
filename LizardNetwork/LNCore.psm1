$moduleName = "LizardNetwork"
$configPath = $env:PSModulePath.Split([System.IO.Path]::PathSeparator)[0] + [System.IO.Path]::DirectorySeparatorChar + `
  $moduleName + [System.IO.Path]::DirectorySeparatorChar + "config.json"

function Import-LNJsonConfig {
  if (Test-Path $configPath) {
    $json = Get-Content $configPath -Raw
    return ($json | ConvertFrom-Json)
  }
}