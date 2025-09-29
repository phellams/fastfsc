#---CONFIG----------------------------
$ModuleConfig            = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName              = $ModuleConfig.moduleName
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
[string]$moduleversion   = $ModuleManifest.Version.ToString()
[string]$PreRelease      = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


if (!(Test-Path -path "./dist/nuget")) { mkdir "./dist/nuget" }
if (!(Test-Path -path "./dist/choco")) { mkdir "./dist/choco" }
if (!(Test-Path -path "./dist/psgal")) { mkdir "./dist/psgal" }

# ===========================================
#                CHOCOLATEY
# ===========================================

$module_source_path = [system.io.path]::combine($pwd, "dist", "$ModuleName")

# release notes are in the form of an hashtable but choco needs a string
[string]$notes = ''
[string]$releaseNotes = "<![CDATA[`n"
if ($ModuleManifest.PrivateData.PSData.ReleaseNotes -is [System.Collections.Hashtable]) {
  $Notes = $ModuleManifest.PrivateData.PSData.ReleaseNotes -join "`n"
}
else {
  $releaseNotes = $ModuleManifest.PrivateData.PSData.ReleaseNotes
}

if ($Notes.Length -gt 0) {
  $releaseNotes = $releaseNotes + $Notes + "`n]]>"
}
else {
  $releaseNotes = $releaseNotes + "No release notes provided.`n]]>"
}

$NuSpecParamsChoco = @{
  path              = $module_source_path
  ModuleName        = $ModuleName
  ModuleVersion     = $ModuleManifest.Version #-replace "\.\d+$", "" # remove the extra .0 as semver has 0.0.0 and powershell 0.0.0.0
  Author            = $ModuleManifest.Author
  Description       = $ModuleManifest.PrivateData.PSData.ChocoDescription
  Summary           = $ModuleManifest.PrivateData.PSData.Summary
  ProjectUrl        = $ModuleManifest.PrivateData.PSData.ProjectUrl
  IconUrl           = $ModuleManifest.PrivateData.PSData.IconUrl
  docsUrl           = $ModuleManifest.PrivateData.PSData.docsUrl
  projectSourceUrl  = $ModuleManifest.PrivateData.PSData.projectSourceUrl 
  MailingListUrl    = $ModuleManifest.PrivateData.PSData.MailingListUrl
  bugTrackerUrl     = $ModuleManifest.PrivateData.PSData.BugTrackerUrl
  LicenseUrl        = $ModuleManifest.PrivateData.PSData.LicenseUrl
  ReleaseNotes      = $releaseNotes
  company           = $ModuleManifest.CompanyName
  Tags              = $ModuleManifest.Tags
  dependencies      = $ModuleManifest.ExternalModuleDependencies
  PreRelease        = $PreRelease
  LicenseAcceptance = $false
}

try {
  # Create New Verification CheckSums Request root module directory
  # Set-Location "./dist/$ModuleName"
  # New-VerificationFile -RootPath ./ -OutputPath ./tools | Format-Table -auto
  # Test-Verification -Path ./ | Format-Table -auto
  # Set-Location ../../ # back
  # Create Choco nuspec
  New-ChocoNuspecFile @NuSpecParamsChoco

  # Use Choco mono to create choco package and deploy
  #New-ChocoPackage -path ".\dist\$ModuleName"  -outpath ".\dist\choco" -ci

} catch {
  [console]::write( "Error creating Choco package: $($_.Exception.Message)`n" )
  exit 1
}