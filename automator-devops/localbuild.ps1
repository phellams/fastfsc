[cmdletbinding()]
param (
    [switch]$Automator,
    [switch]$build,
    [switch]$PsGal,
    [switch]$Nupkg,
    [switch]$ChocoNuSpec,
    [switch]$ChocoNupkgWindows
)

# Import Module config

#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName = $ModuleConfig.moduleName
$moduleVersion = $ModuleConfig.moduleVersion
#---CONFIG----------------------------

# Remove dist folder if it exists
if ( test-path ".\dist" ){ remove-item ".\dist" -Recurse -Force -erroraction silentlycontinue }
else { New-Item -Path .\ -Name "dist" -ItemType Directory }

# local build on windows
if ($isWindows -and !$Automator) {
    [console]::WriteLine("Local Build Windows [ARC] - Importing Modules")
    import-module -Name G:\devspace\projects\powershell\_repos\commitfusion\; # Get-GitAutoVerion extracted and used as standalone
    import-module -name G:\devspace\projects\powershell\_repos\quicklog\;
    import-module -name G:\devspace\projects\powershell\_repos\shelldock\;
    import-module -name G:\devspace\projects\powershell\_repos\psmpacker\; 
    import-module -Name G:\devspace\projects\powershell\_repos\nupsforge\; 
    import-module -name G:\devspace\projects\powershell\_repos\csverify\;   
}
# linux build
if ($isLinux -and !$Automator) {
    [console]::WriteLine("Local Build Linux [ARC] - Importing Modules")
    Import-Module -Name /mnt/g/devspace/projects/powershell/_repos/colorconsole/;
    import-module -Name /mnt/g/devspace/projects/powershell/_repos/commitfusion/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/quicklog/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/shelldock/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/psmpacker/;
    import-module -Name /mnt/g/devspace/projects/powershell/_repos/nupsforge/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/csverify/;
}
# docker phellams/automator
if ($automator) {
    [console]::WriteLine("Local Build Docker Automator [ARC] - Importing Modules")
    # Start WSL2 and run docker as sudo
    # init docker run with remove
    # Change the folder build
    if (!Get-Command wsl){
        [console]::WriteLine("WSL2 not found")
        return
    }

    # Start wsl
    wsl
    sudo docker run --rm -v .:$ModuleName docker.io/sgkens/phellams-automator:latest \ 
        pwsh -c "cd /$modulename; ./automator-devops/scripts/build-module.ps1; ./automator-devops/scripts/build-package-generic-nuget.ps1; ./automator-devops/scripts/build-package-psgallery.ps1"
}

# =================================
# BUILD SCRIPTS
# =================================
if ($build) { ./automator-devops/scripts/build/build-module.ps1 }
if ($psgal) { ./automator-devops/scripts/build/build-package-psgallery.ps1 }
if ($Nupkg) { ./automator-devops/scripts/build/build-package-generic-nuget.ps1 }
if ($ChocoNuSpec) { ./automator-devops/scripts/build/Build-nuspec-choco.ps1 }
if ($ChocoNupkgWindows)   { ./automator-devops/scripts/wip/build-package-choco-windows.ps1  }

# TEST DEPLOY
#./devops/scripts/deploy/deploy-gitlab.ps1
#./devops/scripts/deploy/deploy-psgallary.ps1
#./devops/scripts/deploy-extended-chocolatey.ps1
#./devops/scripts/create-tag.ps1