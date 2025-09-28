#---CONFIG----------------------------
$ModuleConfig            = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName              = $ModuleConfig.moduleName
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
[string]$moduleversion   = $ModuleManifest.Version.ToString()
$PreRelease              = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------

if (!$prerelease -or $prerelease.Length -eq 0) { 
    $moduleversion = $moduleversion 
} else { 
    $moduleversion = "$moduleversion-$prerelease" 
}

$headers = @{ "JOB-TOKEN" = $env:CI_JOB_TOKEN }

# Debug environment variables first
[console]::writeline("=== ENVIRONMENT VARIABLES DEBUG ===")
[console]::writeline("CI_API_V4_URL: $env:CI_API_V4_URL")
[console]::writeline("CI_PROJECT_ID: $env:CI_PROJECT_ID") 
[console]::writeline("CI_COMMIT_TAG: $env:CI_COMMIT_TAG")
[console]::writeline("CI_JOB_TOKEN: $($env:CI_JOB_TOKEN -ne $null)")

# Check if we should use CI_COMMIT_SHA instead of CI_COMMIT_TAG
$versionTag = if ($env:CI_COMMIT_TAG) { $env:CI_COMMIT_TAG } else { $env:CI_COMMIT_SHA }
[console]::writeline("Version Tag: $versionTag")

$baseUrl = "$env:CI_API_V4_URL/projects/$env:CI_PROJECT_ID/packages/generic/module/$versionTag"

# Debug: Show what we're looking for
[console]::writeline("=== MODULE INFO ===")
[console]::writeline("Module Name: $ModuleName")
[console]::writeline("Module Version: $moduleversion")
[console]::writeline("Base URL: $baseUrl")
[console]::writeline("=================================")

# Upload NuGet package
[console]::writeline("Finding NuGet package: $ModuleName-$moduleversion.nupkg to upload...")
$nugetFile = Get-ChildItem -Recurse './dist/nuget' -Filter "$ModuleName*.nupkg" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*.nupkg" } | 
    Select-Object -First 1

if ($nugetFile) {
    $nugetFile | Select-Object Name, FullName
    [console]::writeline("Uploading NuGet package: $($nugetFile.FullName)")
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$($nugetFile.Name)" -Method Put -InFile $nugetFile.FullName -Headers $headers
        [console]::writeline("Upload successful.")
        [console]::writeline("Uploaded: $($nugetFile.Name)")
    }
    catch {
        [console]::writeline("Upload failed: $($_.Exception.Message)")
        exit 1
    }
} else {
    [console]::writeline("No NuGet package found to upload.")
    # List what files are actually there for debugging
    $allNugetFiles = Get-ChildItem -Recurse './dist/nuget' -Filter "*.nupkg" -ErrorAction SilentlyContinue
    if ($allNugetFiles) {
        [console]::writeline("Available NuGet files:")
        $allNugetFiles | ForEach-Object { [console]::writeline("  $($_.Name)") }
    } else {
        [console]::writeline("No .nupkg files found in ./dist/nuget/")
    }
    exit 1
}

# Upload Chocolatey package
[console]::writeline("Finding Chocolatey package: $ModuleName-$moduleversion-choco.nupkg to upload...")
$chocoFile = Get-ChildItem -Recurse './dist/choco' -Filter "$ModuleName*.nupkg" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*choco*.nupkg" } | 
    Select-Object -First 1

if ($chocoFile) {
    $chocoFile | Select-Object Name, FullName
    [console]::writeline("Uploading Chocolatey package: $($chocoFile.Name)")
    try {
        Invoke-RestMethod -Uri "$baseUrl/$($chocoFile.Name)" -Method Put -InFile $chocoFile.FullName -Headers $headers
        [console]::writeline("Uploaded: $($chocoFile.Name)")
    }
    catch {
        [console]::writeline("Chocolatey upload failed: $($_.Exception.Message)")
        exit 1
    }
} else {
    [console]::writeline("No Chocolatey package found to upload.")
    # List what files are actually there for debugging
    $allChocoFiles = Get-ChildItem -Recurse './dist/choco' -Filter "*.nupkg" -ErrorAction SilentlyContinue
    if ($allChocoFiles) {
        [console]::writeline("Available Chocolatey files:")
        $allChocoFiles | ForEach-Object { [console]::writeline("  $($_.Name)") }
    } else {
        [console]::writeline("No .nupkg files found in ./dist/choco/")
    }
    exit 1
}

# Upload ZIP file
[console]::writeline("Finding ZIP file: $ModuleName-$moduleversion-psgal.zip to upload...")
$zipFile = Get-ChildItem -Recurse './dist/psgal' -Filter "$ModuleName*.zip" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*psgal*.zip" } | 
    Select-Object -First 1

if ($zipFile) {
    $zipFile | Select-Object Name, FullName
    [console]::writeline("Uploading ZIP file: $($zipFile.Name)")
    try {
        Invoke-RestMethod -Uri "$baseUrl/$($zipFile.Name)" -Method Put -InFile $zipFile.FullName -Headers $headers
        [console]::writeline("Uploaded: $($zipFile.Name)")
    }
    catch {
        [console]::writeline("ZIP upload failed: $($_.Exception.Message)")
        exit 1
    }
} else {
    [console]::writeline("No ZIP file found to upload.")
    # List what files are actually there for debugging
    $allZipFiles = Get-ChildItem -Recurse './dist/psgal' -Filter "*.zip" -ErrorAction SilentlyContinue
    if ($allZipFiles) {
        [console]::writeline("Available ZIP files:")
        $allZipFiles | ForEach-Object { [console]::writeline("  $($_.Name)") }
    } else {
        [console]::writeline("No .zip files found in ./dist/psgal/")
    }
    exit 1
}