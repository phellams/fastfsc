using module ../../Get-GitAutoVersion.psm1

#---CONFIG----------------------------
$ModuleConfig            = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName              = $ModuleConfig.moduleName
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$prerelease              = $ModuleManifest.PrivateData.PSData.Prerelease
[string]$moduleVersion   = $ModuleManifest.Version
[string[]]$ModuleFiles   = $ModuleConfig.ModuleFiles
[string[]]$ModuleFolders = $ModuleConfig.ModuleFolders
[string[]]$ModuleExclude = $ModuleConfig.ModuleExclude
[string]$moduleName      = $ModuleConfig.moduleName
#---CONFIG----------------------------

$AutoVersion = (Get-GitAutoVersion).Version


if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion } else { $ModuleVersion = "$ModuleVersion-$prerelease" }

# Create dist folder
if (!(Test-Path -Path ./dist)){                                                                         
    New-Item -Path './dist' -ItemType Directory 
}

# for build output
if (!(Test-Path -path "./dist/nuget")) { mkdir "./dist/nuget" }
if (!(Test-Path -path "./dist/choco")) { mkdir "./dist/choco" }
if (!(Test-Path -path "./dist/psgal")) { mkdir "./dist/psgal" }

# for csverify
if (!(Test-Path -Path "./dist/$moduleName/tools")) { 
    New-Item -Path "./dist/$moduleName/tools" -ItemType Directory 
}

# Create ENV as Choco image does not support powershell execution
# Set the choco package name as a ENV and use choco push
# Name will be pulled by the gitlab ci script and use to rename the choco package after choco pack
New-Item -Type File -Path "build.env" -Force -Value $null
$BuildEnvContent = @(
    "CHOCO_NUPKG_PACKAGE_NAME=$ModuleName.$ModuleVersion-choco.nupkg",
    "PSGAL_NUPKG_PACKAGE_NAME=$ModuleName.$ModuleVersion-psgal.nupkg",
    "GITLAB_NUPKG_PACKAGE_NAME=$ModuleName.$ModuleVersion.nupkg",
    "BUILD_PACKAGE_VERSION=$ModuleVersion",
    "BUILD_PACKAGE_NAME=$ModuleName"
)
Set-Content -Path "build.env" -Value $BuildEnvContent -Force -Encoding UTF8

# Copy module files to dist for packaging
Build-Module -SourcePath ./ `
             -DestinationPath './dist' `
             -Name $ModuleName `
             -IncrementVersion None `
             -FilesToCopy $ModuleFiles `
             -FoldersToCopy $ModuleFolders `
             -ExcludedFiles $ModuleExclude `
             -Manifest `
             -Version $AutoVersion
            #  -Dependencies @(@{type="module";name="quicklog";version="1.2.3"})


# NOTE: This is a note