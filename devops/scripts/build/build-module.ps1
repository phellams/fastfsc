using module ../../Get-GitAutoVersion.psm1

#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
[string[]]$ModuleFiles = $ModuleConfig.ModuleFiles
[string[]]$ModuleFolders = $ModuleConfig.ModuleFolders
[string[]]$ModuleExclude = $ModuleConfig.ModuleExclude
[string]$moduleName = $ModuleConfig.moduleName
#---CONFIG----------------------------

$AutoVersion = (Get-GitAutoVersion).Version

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
$choco_package_name = "CHOCO_NUPKG_PACKAGE_NAME=$ModuleName.$moduleVersion-choco.nupkg"
$psgal_package_name = "PSGAL_NUPKG_PACKAGE_NAME=$ModuleName.$moduleVersion-psgal.nupkg"
$gitlab_package_name = "GITLAB_NUPKG_PACKAGE_NAME=$ModuleName.$moduleVersion.nupkg"
$package_version = "BUILD_PACKAGE_VERSION=$ModuleVersion"
$package_name = "BUILD_PACKAGE_NAME=$ModuleName"
$BuildEnvContent = @(
    $choco_package_name,
    $psgal_package_name,
    $gitlab_package_name,
    $package_version,
    $package_name
)

New-Item -Type File -Path "build.env" -Force -Value $null
Set-Content -Path "build.env" -Value $BuildEnvContent -Force -Encoding UTF8


Build-Module -SourcePath ./ `
             -DestinationPath './dist' `
             -Name $moduleName `
             -IncrementVersion None `
             -FilesToCopy $ModuleFiles `
             -FoldersToCopy $ModuleFolders `
             -ExcludedFiles $ModuleExclude `
             -Manifest `
             -Version $AutoVersion
            #  -Dependencies @(@{type="module";name="quicklog";version="1.2.3"})

