# Get the json object from the given file path
function Get-JsonObject([string]$Path) {
  $jsonString = Get-Content $Path -Raw
  return $jsonString | ConvertFrom-Json
}

# Return textures with block faces (top and bottom) if they exist
function Invoke-BlockFaceCheck($Texture) {
  $sourcePathContents = (Get-ChildItem -Path $script:config.$script:configNode.TexturesSourcePath).BaseName
  
  foreach($blockFace in $script:config.$script:configNode.BlockFacesToCheck) {
    if (!$script:config.$script:configNode.TexturesSourcePath -or !(Test-Path $script:config.$script:configNode.TexturesSourcePath)) {
      return $Texture
    }

    $textureWithFace = $Texture + "_" + $blockFace
  
    if ($sourcePathContents.Contains($textureWithFace)) {
      Write-LNInfo -Text "Found $textureWithFace... Using texture!" -Format $script:config.General.Console.DateTimeFormat
      return $textureWithFace
    }
  }

  return $Texture
}

# Gets the object keys
function Get-PSObjectKeys($Object) {
  return ($Object | Get-Member -MemberType NoteProperty).Name
}

function New-Subdirectory([string]$Path) {
  if (!(Test-Path -Path $Path)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
  }
}

# Convert textures and save it into json format
function Start-Logic([string]$JsonPath, [string]$BlockNameToReplace, [string]$NewBlockName) {
  if (!$JsonPath -or !(Test-Path $JsonPath)) {
    Write-LNError -Text "Passed JsonPath `"$JsonPath`" cannot be found!" -Format $script:config.General.Console.DateTimeFormat
    return
  }

  if (!$BlockNameToReplace -or !$NewBlockName ) {
    Write-LNError -Text "Both flags, `"BlockNameToReplace`" and `"NewBlockName`" need to be set!" -Format $script:config.General.Console.DateTimeFormat
    return
  }

  $NewBlockName = $NewBlockName.ToLower()
  $jsonItem = Get-Item $JsonPath
  $jsonDirectoryPath = $jsonItem.Directory.FullName + [System.IO.Path]::DirectorySeparatorChar
  $jsonObject = Get-JsonObject -Path $JsonPath

  foreach ($textureKey in (Get-PSObjectKeys -Object $jsonObject.textures)) {
    $texture = $jsonObject.textures.$textureKey
    $textureName = $texture.Substring($texture.LastIndexOf("/") + 1)
    $texturePath = $texture.Substring($texture.LastIndexOf(":") + 1)
    $textureDirecory = $texturePath.Substring(0, $texturePath.LastIndexOf("/") + 1)

    if ($textureName -eq $BlockNameToReplace) {
      $texturePath = $textureDirecory + $NewBlockName
    }

    if ($script:config.$script:configNode.BlockFacesToCheck) {
      $texturePath = $textureDirecory + (Invoke-BlockFaceCheck -Texture $NewBlockName)
    }

    $jsonObject.textures.$textureKey = $texturePath
  }

  $newPath = $jsonDirectoryPath

  if ($script:config.$script:configNode.CreateSubfolder) {
    $newPath += (Get-LNDefaultOrParameterValue -ParameterValue $script:config.$script:configNode.SubfolderPrefix -DefaultValue "converted_") `
      + $jsonItem.BaseName + [System.IO.Path]::DirectorySeparatorChar
    New-Subdirectory -Path $newPath
  }

  $newPath += $jsonItem.BaseName + "_" + $NewBlockName + $jsonItem.Extension
  $jsonObject | ConvertTo-Json -Compress | Out-File -FilePath $newPath -Encoding utf8
  Write-LNInfo -Text "File has been saved at `"$newPath`"" -Format $script:config.General.Console.DateTimeFormat
}

# Replaces the texture paths of the model json file with the passed one
function Convert-LNTextures([string]$JsonPath, [string]$BlockNameToReplace,  [string]$NewBlockName) {
  $script:configNode = "Convert-LNTextures"
  $script:config = Import-LNJsonConfig
  $defaultTemplatePath = $script:config.$script:configNode.DefaultTemplatePath
  $defaultTemplateBlockToReplace = $script:config.$script:configNode.DefaultTemplateBlockToReplace
  $JsonPath = Get-LNDefaultOrParameterValue -DefaultValue $defaultTemplatePath -ParameterValue $JsonPath
  $BlockNameToReplace = Get-LNDefaultOrParameterValue -DefaultValue $defaultTemplateBlockToReplace -ParameterValue $BlockNameToReplace

  Start-Logic -JsonPath $JsonPath -BlockNameToReplace $BlockNameToReplace -NewBlockName $NewBlockName
}

Set-Alias -Name clnt -Value Convert-LNTextures
Export-ModuleMember -Function Convert-LNTextures -Alias clnt