#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName = $ModuleConfig.moduleName
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$PreRelease = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------



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

try {

  # Create New Verification CheckSums requires root module directory
  set-location "./dist/$ModuleName"
  New-VerificationFile -Path './' -Outpath ' ./tools' | Format-Table -auto
  Test-Verification -Path './' | Format-Table -auto
  Set-location ../../ # back
  # Create Nuget nuspec, Proget, gitlab, PSGallery
  New-NuspecPackageFile @NuSpecParams
  New-NupkgPackage -path "./dist/$ModuleName"  -outpath "./dist/nuget"
  # ===========================================

  # Rename choco package for build artifact as output name is the same 
  # for psgal, nuget and choco
  Rename-Item -Path "./dist/choco/$ModuleName.$moduleVersion.nupkg" `
              -NewName "$ModuleName.$moduleVersion-choco.nupkg"

}
catch {
  [console]::write( "Error creating Nuget Generic package: $($_.Exception.Message)`n" )
  exit 1
}