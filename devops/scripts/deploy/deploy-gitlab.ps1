#---CONFIG----------------------------
$ModuleConfig               = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName                 = $ModuleConfig.moduleName
$ModuleManifest             = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$gitlab_username            = $ModuleConfig.gituser
$gitlab_uri                 = "https://gitlab.com" # https://$($ENV:GITLAB_HOST)"
$projectid                  = $ModuleConfig.gitlabID_public
[string]$moduleversion   = $ModuleManifest.Version.ToString()
$prerelease                 = $ModuleManifest.PrivateData.PSData.Prerelease
$NugetProjectPath           = "api/v4/projects/$projectid/packages/nuget/index.json"
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

try {
  [console]::writeline("Attempting to Register Gitlab: $gitlab_uri@$Gitlab_Username")
  #dotnet nuget add source $gitlab_uri/$NugetProjectPath --name gitlab --username $GitLab_Username --password $ENV:GITLAB_API_KEY
  nuget sources add -name "gitlab_$projectid_$ModuleName`_Packages" -source $gitlab_uri/$NugetProjectPath -username $GitLab_Username -password $env:GITLAB_API_KEY
  [console]::writeline("Successfully registered Gitlab: $gitlab_uri/$NugetProjectPath")
}
catch [system.exception] {
  [console]::writeline("Failed to register Gitlab: $gitlab_uri/$NugetProjectPath")
  [console]::writeline($_.Exception.Message)
  exit 1
}

# check if package already exists
try {
  [console]::writeline("Checking if package exists: $gitlab_uri/$NugetProjectPath")
  $response = Invoke-WebRequest -Uri "https://gitlab.com/api/v4/projects/$projectid/packages/nuget/$ModuleName/$ModuleVersion"
  if ($response.StatusCode -eq 200) {
    [console]::writeline("Package already exists: $gitlab_uri/$NugetProjectPath")
    exit 0
  }
  [console]::writeline("Package does not exist, proceeding to push: $gitlab_uri/$NugetProjectPath")
}
catch {
  [console]::writeline("Package does not exist, proceeding to push: $gitlab_uri/$NugetProjectPath")
}

try {
  [console]::writeline("Pushing $modulename to Gitlab: $gitlab_uri/$NugetProjectPath")
  #dotnet nuget push ./dist/nuget/$modulename.$SemVerVersion.nupkg --source gitlab 
  nuget push ./dist/nuget/$ModuleName.$ModuleVersion.nupkg -Source "gitlab_$projectid_$ModuleName`_Packages" -ApiKey $env:GITLAB_API_KEY
  
  if ($LASTEXITCODE -ne 0) {
    [console]::writeline("Failed to push $modulename to Gitlab: $gitlab_uri/$NugetProjectPath")
    exit 1
  }

  nuget sources remove -Name "gitlab_$projectid_$ModuleName`_Packages"
}
catch [system.exception] {
  [console]::writeline("Failed to push $modulename to Gitlab: $gitlab_uri/$NugetProjectPath")
  [console]::writeline($_.Exception.Message)
  exit 1
}