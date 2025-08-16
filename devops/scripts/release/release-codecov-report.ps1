############## CONFIG ##############
$ModuleConfig   = Get-Content -Path .\build_config.json | ConvertFrom-Json
$ModuleName     = $ModuleConfig.moduleName
$gitgroup       = $ModuleConfig.gitgroup
####################################

# Define the path where you'll download the Codecov Uploader
$codecovUploaderPath = "$PSScriptRoot/codecov" # Or any other suitable path

# 2. Verify the Codecov Uploader is found
if (!(Get-Command $codecovUploaderPath -ErrorAction SilentlyContinue)) {
    throw [System.Exception]::new("Unable to find codecov executable at $codecovUploaderPath")
    break;
}

# 3. Define your coverage report file(s)
# Replace 'coverage.xml' with the actual path to your generated coverage report.
# Common formats are OpenCover XML, Cobertura XML, etc.
$coverageReportFile = "./coverage.xml" # <--- IMPORTANT: Update this path!

if (!(Test-Path $coverageReportFile)) {
    throw [System.Exception]::new("Coverage report file not found: $coverageReportFile. Please ensure your test runner generated it correctly.")
    break;
}

# 4. Upload to Codecov
# Use the -t argument for your Codecov upload token.
# It's highly recommended to store this as an environment variable in your CI/CD.
# Example: $ENV:CODECOV_TOKEN_YOURPROJECTNAME
# You can also use -f to explicitly specify the coverage file.
Write-Host "Uploading coverage report to Codecov..."
try {
    & $codecovUploaderPath upload-process -r "$gitgroup/$ModuleName" -t $env:codecov_token -f $coverageReportFile -v # -v for verbose output

    [console]::writeline("Codecov upload completed.")

}
catch {
    throw [System.Exception]::new("Codecov upload failed: $($_.Exception.Message)")
    # Codecov Uploader itself often exits with a non-zero code on failure,
    # so this catch block might not always be hit depending on how you execute.
}

#.\codecov.exe upload-process -r 'phellams/zypline' -t d8ac6090-6e18-4c6f-abfd-f01db0a88244 -f .\coverage.xml -v