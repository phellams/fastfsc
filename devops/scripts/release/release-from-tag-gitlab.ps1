using module ../core/core.psm1
using module ../core/Test-GitLabReleaseVersion.psm1
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
$release_template = Get-Content -Path './devops/templates/release-template.md' -Raw


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

# nupkg, choco, psgal file hashr
$nuget_nupkg = Get-ItemProperty -Path "./dist/nuget/$modulename.$ModuleVersion.nupkg"
$nuget_nupkg_hash = (Get-FileHash -Path $nuget_nupkg.fullName -Algorithm SHA256).Hash
$choco_nupkg = Get-ItemProperty -Path "./dist/choco/$modulename.$ModuleVersion-choco.nupkg"
$choco_nupkg_hash = (Get-FileHash -Path $choco_nupkg.fullName -Algorithm SHA256).Hash
$psgal_nupkg = Get-ItemProperty -Path "./dist/psgal/$modulename.$ModuleVersion-psgal.zip"
$psgal_zip_hash   = (Get-FileHash -Path $psgal_nupkg.fullName -Algorithm SHA256).Hash

$release_template = $release_template -replace 'REPONAME_PLACE_HOLDER', "$modulename" `
                                      -replace 'VERSION_AND_PRERELEASE_PLACE_HOLDER', "$ModuleVersion" `
                                      -replace 'GITGROUP_PLACE_HOLDER', "$gitgroup" `
                                      -replace 'ONLY_VERSION_PLACE_HOLDER', "$($ModuleVersion.split("-")[0])"`
                                      -replace 'CI_PIPELINE_ID', "$env:CI_PIPELINE_ID" `
                                      -replace 'CI_PIPELINE_URL', "$env:CI_PIPELINE_URL" `
                                      -replace 'COMMIT_SHA', "$env:CI_COMMIT_SHA" `
                                      -replace 'BUILD_DATE', "$(Get-Date -Date $env:CI_PIPELINE_CREATED_AT)" `
                                      -replace 'CI_PROJECT_ID', "$env:CI_PROJECT_ID" `
                                      -replace 'NUGET_NUPKG_HASH', "$nuget_nupkg_hash" `
                                      -replace 'CHOCO_NUPKG_HASH', "$choco_nupkg_hash" `
                                      -replace 'PSGAL_ZIP_HASH', "$psgal_zip_hash"


# Extract package versions using request-genericpackage
$nuget_package = Request-GenericPackage -ProjectId "$env:CI_PROJECT_ID" `
                                        -PackageType "generic" `
                                        -PackageName "$modulename" `
                                        -PackageVersion "$ModuleVersion" `
                                        -ApiKey $ENV:GITLAB_API_KEY `
                                        -ci

$choco_package = Request-GenericPackage -ProjectId "$env:CI_PROJECT_ID" `
                                        -PackageType "generic" `
                                        -PackageName "$modulename" `
                                        -PackageVersion "$ModuleVersion" `
                                        -ApiKey $ENV:GITLAB_API_KEY `
                                        -ci

$psgal_package = Request-GenericPackage -ProjectId "$env:CI_PROJECT_ID" `
                                        -PackageType "generic" `
                                        -PackageName "$modulename" `
                                        -PackageVersion "$ModuleVersion" `
                                        -ApiKey $ENV:GITLAB_API_KEY `
                                        -ci

$assets = @{
  links = @(
    @{
      name      = "$modulename.$moduleversion.nupkg"
      url       = "$ENV:gitlab_host/$($nuget_package.links.web_path)/download"
      #url       = "$env:GITLAB_HOST/$gitgroup/$env:CI_PROJECT_NAME/-/package_files/assets/$ModuleVersion/$modulename-$ModuleVersion.nupkg/download"
      link_type = "package"
    },
    @{
      name      = "$modulename.$moduleversion-choco.nupkg"
      url       = "$ENV:gitlab_host/$($choco_package.links.web_path)/download"
      #url       = "$env:GITLAB_HOST/$gitgroup/$env:CI_PROJECT_NAME/-/package_files/assets/$ModuleVersion/$modulename-$ModuleVersion-choco.nupkg/download"
      link_type = "package"
    },
    @{
      name      = "$modulename.$moduleversion-psgal.zip"
      url       = "$ENV:gitlab_host/$($psgal_package.links.web_path)/download"
      #url       = "$env:GITLAB_HOST/$gitgroup/$env:CI_PROJECT_NAME/-/package_files/assets/$ModuleVersion/$modulename-$ModuleVersion-psgal.zip/download"
      link_type = "package"
    }
  )
}

$headers = @{
  "PRIVATE-TOKEN" = "$env:GITLAB_API_KEY"
  "Content-Type"  = "application/json"
}

$body = @{
    name        = "v$ModuleVersion"
    tag_name    = $ModuleVersion
    description = $release_template
    assets      = $assets
} | ConvertTo-Json -Depth 5

try {
  $interLogger.invoke("release", "Creating release {kv:version=$ModuleVersion} for {kv:module=$gitgroup/$modulename}", $false, 'info')
  $response = Invoke-RestMethod -Uri "$env:CI_API_V4_URL/projects/$($ENV:CI_PROJECT_ID)/releases" `
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