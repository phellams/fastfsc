#---CONFIG----------------------------
$reponame = Get-KeyfromFile -path '.\devops\build_config.json' -key 'ModuleName'
$gituser = Get-KeyfromFile -path '.\devops\build_config.json' -key 'GitGroup' # note: this is the user that will be used to push the tag ie if using group use group name
#---CONFIG----------------------------

install-module -name commitfusion -force | import-module -force

$artifactsUrl = "https://$ENV:GITLAB_HOST/$gituser/$reponame/-/jobs/$($ENV:CI_JOB_ID)/artifacts/raw/dist"
$semver_version = "v$((Get-GitAutoVersion).version)" # requires Module Commit Fusion

# Parse release body
$release_template = Get-Content -Path '.\devops\release-template\release-template.md' -Raw
$release_template   = $release_template -replace $reponame, $modulename `
                                        -replace $chocoRawLink, "$artifactsUrl\choco\$reponame.$version.nupkg"
$release_template   = $release_template -replace $reponame, $modulename `
                                        -replace $chocoRawLink, "$artifactsUrl\nuget\$reponame.$version.nupkg"

$release_template
break;

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
  "name"        = "🍹Release($semver_version)"
  "tag_name"    = "$semver_version"
  "description" = $ReleaseBody
}
