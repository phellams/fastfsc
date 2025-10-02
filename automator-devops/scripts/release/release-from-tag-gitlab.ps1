using module ../core/core.psm1
using module ../core/Test-GitLabReleaseVersion.psm1
using module ../core/Get-RemoteFileHash.psm1
using module ../core/Request-GenericPackage.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__phellams_devops_template.interLogger
$kv = $global:__phellams_devops_template.kvinc
#---UI ELEMENTS Shortened------------

#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$modulename     = $Moduleconfig.moduleName
$ModuleManifest = Test-ModuleManifest -path "./dist/$modulename/$modulename.psd1"
$gitgroup       = $Moduleconfig.gitgroup
$prerelease     = $ModuleManifest.PrivateData.PSData.Prerelease
$ModuleVersion  = $ModuleManifest.Version
#---CONFIG----------------------------

# Parse release body
$release_template = Get-Content -Path './automator-devops/templates/release-template.md' -Raw


if (!$prerelease -or $prerelease.Length -eq 0) { 
  $ModuleVersion = $ModuleVersion
  $release_template = $release_template -replace 'PRERELEASE_CHOCO_PLACE_HOLDER', "" `
                                        -replace 'PRERELEASE_PSGAL_PLACE_HOLDER', "" `
                                        -replace 'PRERELEASE_GITLAB_PLACE_HOLDER' , ""
}
else { 
  $ModuleVersion = "$ModuleVersion-$prerelease" 
  $release_template = $release_template -replace 'PRERELEASE_CHOCO_PLACE_HOLDER', "--prerelease $prerelease" `
                                        -replace 'PRERELEASE_PSGAL_PLACE_HOLDER', "-AllowPrerelease" `
                                        -replace 'PRERELEASE_GITLAB_PLACE_HOLDER' , "-pre"
}

if (Test-GitLabReleaseVersion -reponame "$gitgroup/$modulename" -version $ModuleVersion) {
  $interLogger.invoke("release", "Release {kv:version=$ModuleVersion} already exists for {kv:module=$gitgroup/$modulename}. Skipping release creation.", $false, 'info')
  exit 0
}
else {
  $interLogger.invoke("release", "Release {kv:version=$ModuleVersion} does not exist for {kv:module=$gitgroup/$modulename}. Proceeding to create release.", $false, 'info')
}

$generic_packages = Request-GenericPackage -ProjectId $ENV:CI_PROJECT_ID -PackageName $modulename -ApiKey $ENV:GITLAB_API_KEY -PackageVersion $ModuleVersion

$generic_packages | Format-Table -AutoSize

$nuget_generic_package = ($generic_packages.Where({ $_.file_name -eq "$modulename.$moduleversion.nupkg"} ))[0]
$choco_generic_package = ($generic_packages.Where({ $_.file_name -eq "$modulename.$moduleversion-choco.nupkgw" }))[0]
$psgal_generic_package = ($generic_packages.Where({ $_.file_name -eq "$modulename.$moduleversion-psgal.zip" }))[0]

$interLogger.invoke("release", "DEBUG INFO: DOWNLOAD URL", $false, 'info')
[console]::writeline("====================================")
$kv.invoke("NUGET NUPKG URL", $nuget_generic_package.download_url.toString())
$kv.invoke("CHOCO NUPKG URL", $choco_generic_package.download_url.toString())
$kv.invoke("PSGAL ZIP URL", $psgal_generic_package.download_url.toString())
[console]::writeline("====================================")

$interLogger.invoke("release", "DEBUG INFO: FILE SHA256", $false, 'info')
[console]::writeline("====================================")
$kv.invoke("NUGET NUPKG HASH", $nuget_generic_package.file_sha256)
$kv.invoke("CHOCO NUPKG HASH", $choco_generic_package.file_sha256)
$kv.invoke("PSGAL ZIP HASH", $psgal_generic_package.file_sha256)
[console]::writeline("====================================")

$release_template = $release_template -replace 'REPONAME_PLACE_HOLDER', "$modulename" `
                                      -replace 'VERSION_AND_PRERELEASE_PLACE_HOLDER', "$ModuleVersion" `
                                      -replace 'GITGROUP_PLACE_HOLDER', "$gitgroup" `
                                      -replace 'ONLY_VERSION_PLACE_HOLDER', "$($ModuleVersion.split("-")[0])" `
                                      -replace 'CI_PIPELINE_ID', "$env:CI_PIPELINE_ID" `
                                      -replace 'CI_PIPELINE_URL', "$env:CI_PIPELINE_URL" `
                                      -replace 'COMMIT_SHA', "$env:CI_COMMIT_SHA" `
                                      -replace 'BUILD_DATE', "$(Get-Date -Date $env:CI_PIPELINE_CREATED_AT)" `
                                      -replace 'CI_PROJECT_ID', "$env:CI_PROJECT_ID" `
                                      -replace 'NUGET_NUPKG_HASH', $nuget_generic_package.file_sha256 `
                                      -replace 'CHOCO_NUPKG_HASH', $choco_generic_package.file_sha256 `
                                      -replace 'PSGAL_ZIP_HASH', $psgal_generic_package.file_sha256

$interLogger.invoke("release", "Constructing Assets for {kv:module=$gitgroup/$modulename}", $false, 'info')

$assets = @{
  links = @(
    @{
      name      = "$modulename.$moduleversion.nupkg"
      url       = $nuget_generic_package.download_url
      link_type = "package"
    },
    @{
      name      = "$modulename.$moduleversion-choco.nupkg"
      url       = $choco_generic_package.download_url
      link_type = "package"
    },
    @{
      name      = "$modulename.$moduleversion-psgal.zip"
      url       = $psgal_generic_package.download_url
      link_type = "package"
    }
  )
}

$body = @{
    name        = "v$ModuleVersion"
    tag_name    = $ModuleVersion
    description = $release_template
    assets      = $assets
} | ConvertTo-Json -Depth 10

$headers = @{
  "PRIVATE-TOKEN" = "$env:GITLAB_API_KEY"
  "Content-Type"  = "application/json"
}

$interLogger.invoke("release", "DEBUG INFO", $false, 'info')
[console]::writeline("====================================")
$body
[console]::writeline("====================================")

try {
  $interLogger.invoke("release", "Creating release {kv:version=$ModuleVersion} for {kv:module=$gitgroup/$modulename}", $false, 'info')
  
  $response = Invoke-RestMethod -Uri "$env:CI_API_V4_URL/projects/$ENV:CI_PROJECT_ID/releases" `
                                -Method 'POST' `
                                -Headers $headers `
                                -Body $body 
  
  $interLogger.invoke("release", "Successfully created release {kv:version=$ModuleVersion} for {kv:module=$gitgroup/$modulename}", $false, 'info')
  $interLogger.invoke("release", "Release URL: {kv:url=$($response._links.self)}", $false, 'info')
}
catch {
    $interLogger.invoke("release", "Failed to create release {kv:version=$ModuleVersion} for {kv:module=$gitgroup/$modulename}: {kv:error=$($_.exception.message)}", $false, 'error')
    exit 1
}