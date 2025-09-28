#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName     = $ModuleConfig.moduleName
$gituser        = $ModuleConfig.gituser
$gitgroup       = $ModuleConfig.gitgroup
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$PreRelease     = $ModuleManifest.PrivateData.PSData.Prerelease
$ModuleVersion  = $ModuleManifest.Version.ToString()
$gitlab_host    = "gitlab.com" # $ENV:GITLAB_HOST
#---CONFIG----------------------------

if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

# push Tag
git config --global user.name $gitUser
git config --global user.email "$($ENV:GITLAB_EMAIL)"

git tag "$ModuleVersion"

$git_remote_url = "https://oauth2:$($ENV:GITLAB_API_KEY)@$gitlab_host/$gitgroup/$ModuleName.git"

git push --tags $git_remote_url HEAD:main

if($LASTEXITCODE -ne 0) {
    Write-Host "Failed to push tag $ModuleVersion to $gitgroup/$ModuleName.git"
    exit 1
} else {
    Write-Host "Successfully pushed tag $ModuleVersion to $gitgroup/$ModuleName.git"
}