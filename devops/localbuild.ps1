# Remove dist folder if it exists
if ( test-path ".\dist" ){ remove-item ".\dist" -Recurse -Force -erroraction silentlycontinue }
else { New-Item -Path .\ -Name "dist" -ItemType Directory }

# Import Modules local for now
if($isWindows){
    # Import-Module -Name /mnt/g/devspace/projects/powershell/_repos/colorconsole
    import-module -Name G:\devspace\projects\powershell\_repos\commitfusion\; # Get-GitAutoVerion extracted and used as standalone
    import-module -name G:\devspace\projects\powershell\_repos\quicklog\;
    import-module -name G:\devspace\projects\powershell\_repos\shelldock\;
    import-module -name G:\devspace\projects\powershell\_repos\psmpacker\; 
    import-module -Name G:\devspace\projects\powershell\_repos\nupsforge\; 
    import-module -name G:\devspace\projects\powershell\_repos\csverify\; 
}
if($IsLinux){
    Import-Module -Name /mnt/g/devspace/projects/powershell/_repos/colorconsole
    import-module -Name /mnt/g/devspace/projects/powershell/_repos/commitfusion/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/quicklog/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/shelldock/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/psmpacker/;
    import-module -Name /mnt/g/devspace/projects/powershell/_repos/nupsforge/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/csverify/;
}
# Build the module
#NOTE: Tools folder is automaticlly included in the module, so no need to specify it in the build_config.json

# TEST BUILD
./devops/scripts/build/build-module.ps1 
./devops/scripts/build/build-package-psgallery.ps1
#./devops/scripts/build/build-package-generic-nuget.ps1
#./devops/scripts/build/Build-nuspec-choco.ps1 
# Build for choco is built throw the choco docker mono image
# # for local build only.#./devops/scripts/deploy-psgallary.ps1
#./devops/scripts/build/build-package-choco-windows.ps1 
1
# TEST DEPLOY
#./devops/scripts/deploy/deploy-gitlab.ps1
./devops/scripts/deploy/deploy-psgallary.ps1
#./devops/scripts/deploy-extended-chocolatey.ps1
#./devops/scripts/create-tag.ps1