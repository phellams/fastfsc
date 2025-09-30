function Request-GenericPackage {
    param (
        [parameter(Mandatory=$true)]
        [string]$ProjectId,
        [parameter(Mandatory=$true)]
        [validateset('generic', 'nuget', 'maven', 'npm', 'composer', 'conan', 'pypi')]
        [string]$PackageType,
        [parameter(Mandatory=$false)]
        [string]$PackageName,
        [string]$PackageVersion,
        [string]$ApiUrl,
        [string]$ApiKey,
        [switch]$ci
    )

    # Construct the API URL for fetching the package details
    $url = "$ApiUrl/projects/$ProjectId/packages?package_name=$PackageName&version=$PackageVersion&Type=$PackageType&sort=desc&per_page=1"

     # Default to GitLab's public API if no ApiUrl is provided

    if(!$ApiUrl) {
        $ApiUrl = "https://gitlab.com/api/v4"
    }

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
            return @{
                Id      = $response[0].id
                Name    = $response[0].name
                Version = $response[0].version
                CreatedAt = $response[0].created_at
                Links   = $response[0]._links
            }
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