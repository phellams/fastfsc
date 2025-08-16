#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName = $ModuleConfig.moduleName
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$moduleVersion = $ModuleManifest.Version
$PreRelease = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


if (!(Test-Path -path "./dist/nuget")) { mkdir "./dist/nuget" }
if (!(Test-Path -path "./dist/choco")) { mkdir "./dist/choco" }
if (!(Test-Path -path "./dist/psgal")) { mkdir "./dist/psgal" }

# ===========================================
#                CHOCOLATEY
# ===========================================
# Remove nuspec file from build bold
#Remove-Item -Path "./dist/$ModuleName/$ModuleName.nuspec"

# Choco supports markdown nuget and psgallary done
$markdown_readme = Get-Content -Path ./devops/choco_description.md -Raw `
                               -ErrorAction Stop `
                               -Encoding UTF8 `
                               -Force `
                               -WarningAction SilentlyContinue

$NuSpecParamsChoco = @{
  path              = "./dist/$ModuleName"
  ModuleName        = $ModuleName
  ModuleVersion     = $ModuleManifest.Version #-replace "/.\d+$", "" # remove the extra .0 as semver has 0.0.0 and powershell 0.0.0.0
  Author            = $ModuleManifest.Author
  Description       = $markdown_readme #-replace '```', '```' -replace '\`', '``'
  Summary           = $ModuleManifest.PrivateData.PSData.Summary
  ProjectUrl        = $ModuleManifest.PrivateData.PSData.ProjectUrl
  IconUrl           = $ModuleManifest.PrivateData.PSData.IconUrl
  docsUrl           = $ModuleManifest.PrivateData.PSData.docsUrl
  projectSourceUrl  = $ModuleManifest.PrivateData.PSData.projectSourceUrl 
  MailingListUrl    = $ModuleManifest.PrivateData.PSData.MailingListUrl
  bugTrackerUrl     = $ModuleManifest.PrivateData.PSData.BugTrackerUrl
  LicenseUrl        = $ModuleManifest.PrivateData.PSData.LicenseUrl
  ReleaseNotes      = $ModuleManifest.PrivateData.PSData.ReleaseNotes
  company           = $ModuleManifest.CompanyName
  Tags              = $ModuleManifest.Tags
  dependencies      = $ModuleManifest.ExternalModuleDependencies
  PreRelease        = $PreRelease
  LicenseAcceptance = $false
}

try {

  # Create New Verification CheckSums Request root module directory
  Set-Location "./dist/$ModuleName"
  New-VerificationFile -Path ./ -Output ./tools | Format-Table -auto
  Test-Verification -Path ./tools | Format-Table -auto
  Set-Location ../../ # back
  # Create Choco nuspec
  New-ChocoNuspecFile @NuSpecParamsChoco

  # Create ENV as Choco image does not support powershell execution
  # Set the choco package name as a ENV and use choco push
  $ENV:CHOCO_NUPKG_PACKAGE_NAME = "CHOCO_NUPKG_PACKAGE_NAME=$ModuleName.$moduleVersion"

  New-ChocoPackage -path "./dist/$ModuleName"  -outpath "./dist/choco"

  # Rename choco package for build artifact as output name is the same 
  # for psgal, nuget and choco
  Rename-Item -Path "./dist/choco/$ModuleName.$moduleVersion.nupkg" `
              -NewName "$ModuleName.$moduleVersion-choco.nupkg"
} catch {
  [console]::write( "Error creating Choco package: $($_.Exception.Message)`n" )
  exit 1
}