#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName = $ModuleConfig.moduleName
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$PreRelease = $ModuleManifest.PrivateData.PSData.Prerelease
$ModuleVersion = $ModuleManifest.Version #-replace "/./d+$", ""
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

# ===========================================
#             PowerShell Gallery
# ===========================================

if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

set-location "./dist/$ModuleName"
New-VerificationFile -RootPath '.\' -OutputPath '.\tools' | Format-Table -auto

Test-Verification -Path '.\' | Format-Table -auto
Set-location ../../ # back
# Create Nuget nuspec, Proget, gitlab, PSGallery
New-NuspecPackageFile @NuSpecParams

# Create Zip With .nuspec file for PSGallery
# copy-item -recurse -path "./dist/$ModuleName" -destination "./dist/psgal/$ModuleName"
$zipFileName = "$ModuleName-$ModuleVersion.zip"
[console]::write( "Creating Zip File for PSGallery `n" )
[console]::write( "Source: ./dist/$($ModuleName)/* `n" )
[console]::write( "output: ./dist/psgal/$($zipFileName) `n" )

try{
  compress-archive -path "./dist/$ModuleName/*" `
                   -destinationpath "./dist/psgal/$zipFileName" `
                   -compressionlevel optimal `
                   -update
}catch {
  [console]::write( "Error creating PSGallery package: $($_.Exception.Message)`n" )
  exit 1
}