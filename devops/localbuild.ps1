param (
    [switch]$localBuild,
    [switch]$wslBuild,
    [switch]$Automator,
    [switch]$Linux
)

# Remove dist folder if it exists
if ( test-path ".\dist" ){ remove-item ".\dist" -Recurse -Force -erroraction silentlycontinue }
else { New-Item -Path .\ -Name "dist" -ItemType Directory }

# local build on windows
if ($localBuild) {
    import-module -Name G:\devspace\projects\powershell\_repos\commitfusion\; # Get-GitAutoVerion extracted and used as standalone
    import-module -name G:\devspace\projects\powershell\_repos\quicklog\;
    import-module -name G:\devspace\projects\powershell\_repos\shelldock\;
    import-module -name G:\devspace\projects\powershell\_repos\psmpacker\; 
    import-module -Name G:\devspace\projects\powershell\_repos\nupsforge\; 
    import-module -name G:\devspace\projects\powershell\_repos\csverify\;   
}
# local build on WSL
if ($wslBuild) {
    Import-Module -Name /mnt/g/devspace/projects/powershell/_repos/colorconsole
    import-module -Name /mnt/g/devspace/projects/powershell/_repos/commitfusion/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/quicklog/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/shelldock/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/psmpacker/;
    import-module -Name /mnt/g/devspace/projects/powershell/_repos/nupsforge/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/csverify/;
}
# linux build
if ($Linux) {

}
# docker phellams/automator
if ($automator) {

}

# =================================
# BUILD SCRIPTS
# =================================
if ($build)        { ./devops/scripts/build/build-module.ps1 }
if ($PsGalNupkg)   { ./devops/scripts/build/build-package-psgallery.ps1 }
if ($GenericNupkg) { ./devops/scripts/build/build-package-generic-nuget.ps1 }
if ($ChocoNuSpec)  { ./devops/scripts/build/Build-nuspec-choco.ps1 }
if ($ChocoNupkgWindows)   { ./devops/scripts/build/build-package-choco-windows.ps1  }

1
# TEST DEPLOY
#./devops/scripts/deploy/deploy-gitlab.ps1
#./devops/scripts/deploy/deploy-psgallary.ps1
#./devops/scripts/deploy-extended-chocolatey.ps1
#./devops/scripts/create-tag.ps1