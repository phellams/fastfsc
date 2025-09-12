#---CONFIG----------------------------
$ModuleConfig            = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName              = $ModuleConfig.moduleName
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
[string]$moduleversion   = $ModuleManifest.Version.ToString()
$PreRelease              = $ModuleManifest.PrivateData.PSData.Prerelease

#---CONFIG----------------------------
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

$headers = @{ "JOB-TOKEN" = $env:CI_JOB_TOKEN }
$baseUrl = "$env:CI_API_V4_URL/projects/$env:CI_PROJECT_ID/packages/generic/module/$env:CI_COMMIT_TAG"

# Upload NuGet package
[console]::writeline("Finding NuGet package: $ModuleName-$ModuleVersion to upload...")
$nugetFile = Get-ChildItem -Recurse './dist/nuget' -Filter "$ModuleName-$ModuleVersion.nupkg" | Select-Object -First 1
if ($null -ne $nugetFile) {
    [console]::writeline("Uploading NuGet package: $($nugetFile.Name)")
    Invoke-RestMethod -Uri "$baseUrl/$($nugetFile.Name)" -Method Put -InFile $nugetFile.FullName -Headers $headers
    [console]::writeline("Uploaded: $($nugetFile.Name)")
}else {
    [console]::writeline("No NuGet package found to upload.")
    exit 1
}

# Upload Chocolatey package
[console]::writeline("Finding Chocolatey package: $ModuleName-$ModuleVersion-choco.nupkg to upload...")
$chocoFile = Get-ChildItem -Recurse ./dist/choco -Filter "$ModuleName-$ModuleVersion-choco.nupkg" | Select-Object -First 1
if ($null -ne $chocoFile) {
    [console]::writeline("Uploading Chocolatey package: $($chocoFile.Name)")
    Invoke-RestMethod -Uri "$baseUrl/$($chocoFile.Name)" -Method Put -InFile $chocoFile.FullName -Headers $headers
    [console]::writeline("Uploaded: $($chocoFile.Name)")
}else {
    [console]::writeline("No Chocolatey package found to upload.")
    exit 1
}

# Upload ZIP file
[console]::writeline("Finding ZIP file: $ModuleName-$ModuleVersion-psgal.zip to upload...")
$zipFile = Get-ChildItem -Recurse ./dist/psgal -Filter "$ModuleName-$ModuleVersion-psgal.zip" | Select-Object -First 1
if ($null -ne $zipFile) {
    [console]::writeline("Uploading ZIP file: $($zipFile.Name)")
    Invoke-RestMethod -Uri "$baseUrl/$($zipFile.Name)" -Method Put -InFile $zipFile.FullName -Headers $headers
    [console]::writeline("Uploaded: $($zipFile.Name)")
}else {
    [console]::writeline("No ZIP file found to upload.")
    exit 1
}