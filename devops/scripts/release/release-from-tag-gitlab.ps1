#---CONFIG----------------------------
$Moduleconfig = Get-Content -Path .\devops\build_config.json | ConvertFrom-Json
$modulename = $Moduleconfig.moduleName
$ModuleManifest = Test-ModuleManifest -path ".\dist\$modulename\$modulename.psd1"
$gitgroup = $Moduleconfig.gitgroup
$prerelease = $ModuleManifest.PrivateData.PSData.Prerelease
$ModuleVersion = $ModuleManifest.Version
#---CONFIG----------------------------

$artifactsUrl = "https://gitlab.com/$gituser/$modulename/-/jobs/$($ENV:CI_JOB_ID)/artifacts/raw/dist"
$semver_version = "v$((Get-GitAutoVersion).version)" # requires Module Commit Fusion

# Parse release body
$release_template = Get-Content -Path '.\devops\templates\release-template.md' -Raw


if (!$prerelease -or $prerelease.Length -eq 0) { 
  $ModuleVersion = $ModuleVersion
}
else { 
  $ModuleVersion = "$ModuleVersion-$prerelease" 
  $release_template = $release_template -replace 'PRERELEASE_CHOCO_PLACE_HOLDER', "--prerelease $prerelease" `
                                        -replace 'PRERELEASE_PSGAL_PLACE_HOLDER', "-AllowPrerelease"
}
$release_template = $release_template -replace 'REPONAME_PLACE_HOLDER', "$modulename" `
                                      -replace 'CHOCO_ARTIFACT_PLACE_HOLDER', "$artifactsUrl\choco\$modulename.$ModuleVersion.nupkg" `
                                      -replace 'PSGAL_ARTIFACT_PLACE_HOLDER', "$artifactsUrl\nuget\$modulename.$ModuleVersion.nupkg" `
                                      -replace 'NUGET_ARTIFACT_PLACE_HOLDER', "$artifactsUrl\nuget\$modulename.$ModuleVersion.nupkg" `
                                      -replace 'VERSION_AND_PRERELEASE_PLACE_HOLDER', "$ModuleVersion" `
                                      -replace 'GITGROUP_PLACE_HOLDER', "$gitgroup" `
                                      -replace 'ONLY_VERSION_PLACE_HOLDER', "$($ModuleVersion.split("-")[0])"


# $nupkgFiles = Get-ChildItem -Path './build' -Filter '*.nupkg'
# $zip = Get-ChildItem -Path './build' -Filter '*.zip'

# foreach ($file in $nupkgFiles) {
#     $description += "`n- [$($file.Name)]($artifactsUrl/$($file.Name))"
# }

# $ReleaseNotes = ""
# $Packages = ""
# $nupkgFiles = ""
$headers = New-Object 'System.Collections.Generic.Dictionary[[String],[String]]'
$headers.Add("PRIVATE-TOKEN", "$($ENV:GITLAB_API_KEY)")
$headers.Add("Content-Type", "application/json")
Invoke-RestMethod -Uri "https://$ENV:GITLAB_HOST/api/v4/projects/$($ENV:CI_PROJECT_ID)/releases" -Method 'POST' -Headers $headers -Body @{
  "name"        = "Release v$semver_version"
  "tag_name"    = "$semver_version"
  "description" = $release_template
}
