#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName = $ModuleConfig.moduleName
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$ModuleVersion = $ModuleManifest.Version #-replace "/./d+$",""
$PreRelease = $ModuleManifest.PrivateData.PSData.Prerelease

#---CONFIG----------------------------
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

$headers = @{ "JOB-TOKEN" = $env:CI_JOB_TOKEN }
$baseUrl = "$env:CI_API_V4_URL/projects/$env:CI_PROJECT_ID/packages/generic/module/$env:CI_COMMIT_TAG"

# Upload NuGet package
$nugetFile = Get-ChildItem -Filter "$modulename-$ModuleVersion.nupkg" | Where-Object { $_.Name -notlike "*-choco*" } | Select-Object -First 1
if ($nugetFile) {
    Invoke-RestMethod -Uri "$baseUrl/$($nugetFile.Name)" -Method Put -InFile $nugetFile.FullName -Headers $headers
    Write-Host "Uploaded: $($nugetFile.Name)"
}else {
    Write-Host "No NuGet package found to upload."
    exit 1
}

# Upload Chocolatey package
$chocoFile = Get-ChildItem -Filter "$modulename-$ModuleVersion-choco.nupkg" | Select-Object -First 1
if ($chocoFile) {
    Invoke-RestMethod -Uri "$baseUrl/$($chocoFile.Name)" -Method Put -InFile $chocoFile.FullName -Headers $headers
    Write-Host "Uploaded: $($chocoFile.Name)"
}else {
    Write-Host "No Chocolatey package found to upload."
    exit 1
}

# Upload ZIP file
$zipFile = Get-ChildItem -Filter "$modulename-$ModuleVersion.zip" | Select-Object -First 1
if ($zipFile) {
    Invoke-RestMethod -Uri "$baseUrl/$($zipFile.Name)" -Method Put -InFile $zipFile.FullName -Headers $headers
    Write-Host "Uploaded: $($zipFile.Name)"
}else {
    Write-Host "No ZIP file found to upload."
    exit 1
}