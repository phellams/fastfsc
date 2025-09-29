using module ../../Get-GitAutoVersion.psm1

#---CONFIG----------------------------
$ModuleConfig            = Get-Content -Path ./build_config.json | ConvertFrom-Json
[string]$ModuleName      = $ModuleConfig.moduleName
[string[]]$ModuleFiles   = $ModuleConfig.ModuleFiles
[string[]]$ModuleFolders = $ModuleConfig.ModuleFolders
[string[]]$ModuleExclude = $ModuleConfig.ModuleExclude
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



# Create ENV as Choco image does not support powershell execution
# Set the choco package name as a ENV and use choco push
# Name will be pulled by the gitlab ci script and use to rename the choco package after choco pack
if((Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1")) {
    [console]::writeline("Module manifest found at ./dist/$ModuleName/$ModuleName.psd1")    
} else {
    [console]::writeline("Module manifest not found at ./dist/$ModuleName/$ModuleName.psd1")
    exit 1

}
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
[string]$prerelease      = $ModuleManifest.PrivateData.PSData.Prerelease
[string]$moduleversion   = $ModuleManifest.Version.ToString()

if (!$prerelease -or $prerelease.Length -eq 0) { $moduleversion = $moduleversion }
else { $moduleversion = "$moduleversion-$prerelease" }

New-Item -Type File -Path "build.env" -Force -Value $null

$BuildEnvContent = @(
    "CHOCO_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion.nupkg",
    "PSGAL_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion-psgal.nupkg",
    "GITLAB_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion.nupkg",
    "BUILD_PACKAGE_VERSION=$moduleversion",
    "BUILD_PACKAGE_NAME=$ModuleName"
)

# Echo out build env
Write-Host "CHOCO_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion-choco.nupkg"
Write-Host "PSGAL_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion-psgal.nupkg"
Write-Host "GITLAB_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion.nupkg"
Write-Host "BUILD_PACKAGE_VERSION=$moduleversion"
Write-Host "BUILD_PACKAGE_NAME=$ModuleName"

Set-Content -Path "build.env" -Value $BuildEnvContent -Force -Encoding UTF8

# NOTE: This is a note