# Will be used to check for existing blocks with different faces (top and bottom)
$texturesSourcePath = "Path of the vanilla \textures\block files"

# Get the json object from the given file path
function Get-JsonObject([string]$Path) {
  $jsonString = Get-Content $Path -Raw
  return $jsonString | ConvertFrom-Json
}

# Return textures with block faces (top and bottom) if they exist
function Invoke-BlockCheck($Texture, $BlockFace) {
  if (!$texturesSourcePath -or !(Test-Path $texturesSourcePath)) {
    return $Texture
  }

  $sourcePathContents = (Get-ChildItem -Path $texturesSourcePath).BaseName
  $textureWithFace = $Texture + "_" + $BlockFace

  if ($sourcePathContents.Contains($textureWithFace)) {
    "INF:`tFound $textureWithFace... Using texture!" | Out-Host
    return $textureWithFace
  }

  return $Texture
}

# Gets the object keys
function Get-PSObjectKeys($Object) {
  return ($Object | Get-Member -MemberType NoteProperty).Name
}

# Convert textures and save it into json format
function Convert-LNTextures([string]$JsonPath, [string]$ImageName, [string]$ReplaceImageName) {
  if (!$JsonPath -or !(Test-Path $JsonPath)) {
    "ERR:`tPassed JsonPath `"$JsonPath`" cannot be found!" | Out-Host
    return
  }

  if (!$ImageName -or !$ReplaceImageName ) {
    "ERR:`tBoth flags, `"ImageName`" and `"ReplaceImageName`" need to be set!" | Out-Host
    return
  }

  $ReplaceImageName = $ReplaceImageName.ToLower()
  $jsonItem = Get-Item $JsonPath
  $jsonDirectoryPath = $jsonItem.Directory.FullName + [System.IO.Path]::DirectorySeparatorChar
  $jsonObject = Get-JsonObject -Path $JsonPath

  foreach ($textureKey in (Get-PSObjectKeys -Object $jsonObject.textures)) {
    $texture = $jsonObject.textures.$textureKey
    $textureName = $texture.Substring($texture.LastIndexOf("/") + 1)
    $texturePath = $texture.Substring($texture.LastIndexOf(":") + 1)
    $textureDirecory = $texturePath.Substring(0, $texturePath.LastIndexOf("/") + 1)

    if ($textureName -eq $ImageName) {
      $texturePath = $textureDirecory + $ReplaceImageName
    }

    if ($textureName.EndsWith("_top")) {
      $texturePath = $textureDirecory + (Invoke-BlockCheck -Texture $ReplaceImageName -BlockFace "top")
    }

    if ($textureName.EndsWith("_bottom")) {
      $texturePath = $textureDirecory + (Invoke-BlockCheck -Texture $ReplaceImageName -BlockFace "bottom")
    }

    $jsonObject.textures.$textureKey = $texturePath
  }

  $newFilePath = $jsonDirectoryPath + $jsonItem.BaseName + "_" + $ReplaceImageName + $jsonItem.Extension
  $jsonObject | ConvertTo-Json -Compress | Out-File -FilePath $newFilePath -Encoding utf8
  "File has been saved at `"$newFilePath`""
}

Export-ModuleMember -Function Convert-LNTextures -Alias "clnt"