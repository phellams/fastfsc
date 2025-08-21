#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName     = $ModuleConfig.moduleName
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$ModuleVersion  = $ModuleManifest.version
$PreRelease     = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


# Check if pre-release if so check name to reflect

if (!(Test-Path -path "./dist/nuget")) { mkdir "./dist/nuget" }
if (!(Test-Path -path "./dist/choco")) { mkdir "./dist/choco" }
if (!(Test-Path -path "./dist/psgal")) { mkdir "./dist/psgal" }



# ===========================================
# https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js
# ===========================================
$NuSpecParams = @{
  path          = "./dist/$ModuleName"
  ModuleName    = $ModuleName
  ModuleVersion = $ModuleManifest.Version #-replace "/./d+$", ""
  Author        = $ModuleManifest.Author
  Description   = $ModuleManifest.Description
  ProjectUrl    = $ModuleManifest.PrivateData.PSData.ProjectUri
  License       = $ModuleConfig.License
  company       = $ModuleManifest.CompanyName
  Tags          = $ModuleManifest.Tags
  dependencies  = $ModuleManifest.ExternalModuleDependencies
  PreRelease    = $PreRelease
}



# Create New Verification CheckSums requires root module directory
set-location "./dist/$ModuleName"
New-VerificationFile -RootPath ./ -OutputPath ./tools | Format-Table -auto
Test-Verification -Path ./ | Format-Table -auto
Set-location ../../ # back


try {
  # Create Nuget nuspec, Proget, gitlab, PSGallery
  New-NuspecPackageFile @NuSpecParams
  New-NupkgPackage -path "./dist/$ModuleName"  -outpath "./dist/nuget" -ci
}
catch {
  [console]::write( "Error creating Nuget Generic package: $($_.Exception.Message)`n" )
  exit 1
}