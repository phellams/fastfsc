#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName     = $ModuleConfig.moduleName
$gituser        = $ModuleConfig.gituser
$gitgroup       = $ModuleConfig.gitgroup
#$gitlab_mirror_name = "gitlab_mirror"
$github_mirror_name = "github_mirror"
    #---CONFIG----------------------------

try {


    # $repo_string = "https://$user`:$ENV:GITLAB_API_KEY@$gitlab.com/$user/$RepoName.git"
    # git remote add $gitlab_mirror_name $repo_string
    # git remote set-url --push $name $repo_string
    # git push $gitlab_mirror_name --all
    # if($LASTEXITCODE -eq 0) {
    #     Write-Host "Gitlab Mirror Added" #! should throw here for ci to fail
    # }else {
    #     throw [system.exception] "Failed to add Gitlab Mirror Exit Code:$LASTEXITCODE, url:$repo_string"
    # }

    # ADD local Mirror - Github
    # -----------------
    $repo_string = "https://$gituser`:$ENV:GITHUB_API_KEY@github.com/$gitgroup/$ModuleName.git"
    git remote add $github_mirror_name $repo_string
    git remote set-url --push $github_mirror_name $repo_string
    [console]::write("Adding Github Mirror: $repo_string`n")
    git push $github_mirror_name --all
    if($LASTEXITCODE -eq 0) {
        Write-Host "Github Mirror Added" #! should throw here for ci to fail
    }else {
        [console]::write("Failed to add Github Mirror Exit Code:$LASTEXITCODE, url:$repo_string`n")
        exit 1
    }

} catch [system.exception] {
    [console]::write("failed to create local mirror: $($_.exception.message)`n")
    
}

# Remove local Mirrors
# -----------------
#git remote remove gitlab_mirror
git remote remove github_mirror
