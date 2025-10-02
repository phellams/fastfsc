function Request-GenericPackage {
    param (
        [parameter(Mandatory=$true)]
        [string]$ProjectId,
        [parameter(Mandatory=$false)]
        [string]$PackageName,
        [string]$PackageVersion,
        [string]$ApiUrl,
        [string]$ApiKey,
        [switch]$ci
    )

     # Default to GitLab's public API if no ApiUrl is provided

    if(!$ApiUrl) {
        $ApiUrl = "https://gitlab.com/api/v4"
    }

    # Construct the API URL for fetching the package details
    $url = "$ApiUrl/projects/$ProjectId/packages?package_name=$PackageName&package_version=$PackageVersion&package_Type=generic"

    if(!$apikey -and $ci) {
        $env:GITLAB_API_KEY = $ApiKey
    }
    
    Write-Host "Requesting package info from URL: $url"
    
    $headers = @{
        "PRIVATE-TOKEN" = "$env:GITLAB_API_KEY"
        "Content-Type"  = "application/json"
    }
     # Make the API request to get package details

    try {
        # Make the API request to get package details
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $Headers

        if ($response -and $response.Count -gt 0) {
            $generic_package_id = $response[0].id
            $package_files = Invoke-RestMethod -Uri "$ApiUrl/projects/$ProjectId/packages/$generic_package_id/package_files"
            
            $generic_package_files_reponse = @()

            foreach($package in $package_files){
                $download_url = "$apiurl/project/$projectid/packages/$generic_package_id/package_files/$($package.id)/download"
                $generic_package_files_reponse += [pscustomobject]@{
                    package_id   = $package.package_id
                    id           = $package.id
                    file_name    = $package.file_name
                    file_sha256  = $package.file_sha256
                    size         = $package.size
                    download_url = $download_url
                }
            }
            return $generic_package_files_reponse
        } else {
            Write-Error "No package found with name '$PackageName' and version '$PackageVersion'."
            return $null
        }
    } catch {
        Write-Error "Failed to retrieve package information: $_"
        return $null
    }
}

$cmdlet_config = @{
    function = @(
        'Request-GenericPackage'
    )
    alias = @()
}

Export-ModuleMember @cmdlet_config

# Example usage:
# Request-GenericPackage -ProjectId "72971048" -PackageType "generic" -PackageName "fastfsc" -PackageVersion "v0.4.0-prerelease" -ApiUrl "https://gitlab.com/api/v4" -ApiKey $ENV:GITLAB_API_KEY