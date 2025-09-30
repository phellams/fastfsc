using module ../core/Get-GitAutoVersion.psm1
using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__phellams_devops_template.interLogger
$kv          = $global:__phellams_devops_template.kvinc
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$ModuleConfig            = Get-Content -Path ./build_config.json | ConvertFrom-Json
[string]$ModuleName      = $ModuleConfig.moduleName
[string[]]$ModuleFiles   = $ModuleConfig.ModuleFiles
[string[]]$ModuleFolders = $ModuleConfig.ModuleFolders
[string[]]$ModuleExclude = $ModuleConfig.ModuleExclude
#---CONFIG----------------------------

$AutoVersion = (Get-GitAutoVersion).Version

$interLogger.invoke("Build", "Running Build on {kv:module=$ModuleName} ", $false, 'info')
$interLogger.invoke("Build", "Creating dist folders", $false, 'info')

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

$interLogger.invoke("Build", "Copying files to dist {inf:kv:BuildSource=PSMPacker}", $false, 'info')

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
    $interLogger.invoke("Build", "Module manifest found at ./dist/$ModuleName/$ModuleName.psd1", $false, 'info') 
} else {
    $interLogger.invoke("Build", "Module manifest not found at ./dist/$ModuleName/$ModuleName.psd1", $false, 'error')
    exit 1

}
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
[string]$prerelease      = $ModuleManifest.PrivateData.PSData.Prerelease
[string]$moduleversion   = $ModuleManifest.Version.ToString()

if (!$prerelease -or $prerelease.Length -eq 0) { $moduleversion = $moduleversion }
else { $moduleversion = "$moduleversion-$prerelease" }

$interLogger.invoke("Build", "Module version is {kv:version=$moduleversion}", $false, 'info')
$interLogger.invoke("Build", "Generating build env {kv:path=./build.env}", $false, 'info')

New-Item -Type File -Path "build.env" -Force -Value $null

$BuildEnvContent = @(
    "CHOCO_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion.nupkg",
    "PSGAL_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion-psgal.nupkg",
    "GITLAB_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion.nupkg",
    "BUILD_PACKAGE_VERSION=$moduleversion",
    "BUILD_PACKAGE_NAME=$ModuleName"
)

# Echo out build env
$kv.invoke("CHOCO_NUPKG_PACKAGE_NAME", "$ModuleName.$moduleversion-choco.nupkg")
$kv.invoke("PSGAL_NUPKG_PACKAGE_NAME", "$ModuleName.$moduleversion-psgal.nupkg")
$kv.invoke("GITLAB_NUPKG_PACKAGE_NAME", "$ModuleName.$moduleversion.nupkg")
$kv.invoke("BUILD_PACKAGE_VERSION", "$moduleversion")
$kv.invoke("BUILD_PACKAGE_NAME", "$ModuleName")

Set-Content -Path "build.env" -Value $BuildEnvContent -Force -Encoding UTF8

# NOTE: This is a note