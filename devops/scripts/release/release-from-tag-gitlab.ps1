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
}
else { 
  $ModuleVersion = "$ModuleVersion-$prerelease" 
  $release_template = $release_template -replace 'PRERELEASE_CHOCO_PLACE_HOLDER', "--prerelease $prerelease" `
                                        -replace 'PRERELEASE_PSGAL_PLACE_HOLDER', "-AllowPrerelease"
}

$assets = @{
  links = @(
    @{
      name      = "NuGet Package"
      url       = "$env:CI_API_V4_URL/projects/$env:CI_PROJECT_ID/packages/generic/module/$env:CI_COMMIT_TAG/$modulename-$ModuleVersion.nupkg"
      link_type = "package"
    },
    @{
      name      = "Chocolatey Package"
      url       = "$env:CI_API_V4_URL/projects/$env:CI_PROJECT_ID/packages/generic/module/$env:CI_COMMIT_TAG/$modulename-$ModuleVersion-choco.nupkg"
      link_type = "package"
    },
    @{
      name      = "ZIP Archive"
      url       = "$env:CI_API_V4_URL/projects/$env:CI_PROJECT_ID/packages/generic/module/$env:CI_COMMIT_TAG/module-$env:CI_COMMIT_TAG.zip"
      link_type = "package"
    }
  )
}


$release_template = $release_template -replace 'REPONAME_PLACE_HOLDER', "$modulename" `
                                      -replace 'CHOCO_ARTIFACT_PLACE_HOLDER', $assets.links.where({$_.name -eq "Chocolatey Package"}) `
                                      -replace 'PSGAL_ARTIFACT_PLACE_HOLDER', $assets.links.where({$_.name -eq "NuGet Package"}) `
                                      -replace 'NUGET_ARTIFACT_PLACE_HOLDER', $assets.links.where({$_.name -eq "NuGet Package"}) `
                                      -replace 'VERSION_AND_PRERELEASE_PLACE_HOLDER', "$ModuleVersion" `
                                      -replace 'GITGROUP_PLACE_HOLDER', "$gitgroup" `
                                      -replace 'ONLY_VERSION_PLACE_HOLDER', "$($ModuleVersion.split("-")[0])"

$headers = New-Object 'System.Collections.Generic.Dictionary[[String],[String]]'
$headers.Add("PRIVATE-TOKEN", "$($ENV:GITLAB_API_KEY)")
$headers.Add("Content-Type", "application/json")

try {
  Invoke-RestMethod -Uri "https://$ENV:GITLAB_HOST/api/v4/projects/$($ENV:CI_PROJECT_ID)/releases" -Method 'POST' -Headers $headers -Body @{
    name        = "Release v$ModuleVersion"
    tag_name    = $ModuleVersion
    description = $release_template
    assets      = $assets
  }

  Write-Host "✅ Release created successfully: $($response.tag_name)"
  Write-Host "🔗 Release URL: $($response._links.self)"
}
catch {
    Write-Error "❌ Failed to create release: $($_.Exception.Message)"
    Write-Error "Response: $($_.Exception.Response)"
    exit 1
}