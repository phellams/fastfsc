#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path .\devops\build_config.json | ConvertFrom-Json
$ModuleName = $ModuleConfig.moduleName
$gituser = $ModuleConfig.gituser
$gitgroup = $ModuleConfig.gitgroup
$ModuleManifest = Test-ModuleManifest -path ".\dist\$ModuleName\$ModuleName.psd1"
$PreRelease = $ModuleManifest.PrivateData.PSData.Prerelease
$ModuleVersion = $ModuleManifest.Version.ToString()
$gitlab_host = "gitlab.com" # $ENV:GITLAB_HOST
#---CONFIG----------------------------

if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

# push Tag
git config --global user.name $gitUser
git config --global user.email "$($ENV:GITLAB_EMAIL)"

git tag "$ModuleVersion"
git push --tags https://${GITLAB_PUBLIC_API_KEY}@$gitlab_host/$gitgroup/$ModuleName.git HEAD:main