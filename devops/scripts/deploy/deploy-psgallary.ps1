#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$modulename     = $ModuleConfig.modulename
$ModuleManifest = Test-ModuleManifest -path "./dist/$moduleName/$moduleName.psd1"
$ModuleVersion  = $ModuleManifest.Version
$prerelease     = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


# Check if module version exists
$psgal_curretnversion = Find-Module -Name $modulename -Repository 'psgallery' | Select-Object -ExpandProperty Version
if ($psgal_curretnversion -eq $ModuleVersion) {
  [console]::writeline("Module version $ModuleVersion already exists in PSGallery")
  exit 0
} else {
  [console]::writeline("Module version $ModuleVersion does not exist in PSGallery")
}

# Publish to PSGallery if version does not exist
try {
  [console]::writeline("Attempting to publish $modulename to PSGallery")
  publish-Module `
    -path "./dist/$modulename" `
    -Repository 'psgallery' `
    -NuGetApiKey $ENV:PSGAL_API_KEY `
    -projecturi $ModuleManifest.PrivateData.PSData.ProjectUri `
    -licenseuri $ModuleManifest.PrivateData.PSData.LicenseUri `
    -IconUri $ModuleManifest.PrivateData.PSData.IconUri `
    -ReleaseNotes $ModuleManifest.ReleaseNotes `
    -Tags $ModuleManifest.Tags `
    -Verbose

} catch {
  [console]::writeline("Failed to publish $modulename to PSGallery")
  [console]::writeline("Error details:")
  [console]::writeline($_.Exception.Message)
  exit 1
}

#NOTE: Update this in gitlab
#NOTE: Also update build template script
#NOTE: This is the version that will be used in the build pipeline