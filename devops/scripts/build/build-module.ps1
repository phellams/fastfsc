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
