using module ..\keyfile\keyfile.psm1 # Import Get-KeyFromFile
#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path .\devops\build_config.json | ConvertFrom-Json
$ModuleManifest = Test-ModuleManifest -path ".\dist\$moduleName\$moduleName`.psd1"
#---CONFIG----------------------------

Invoke-ScriptAnalyzer -Path .\dist\$modulename `
                      -Recurse `
                      -severity warning `
                      -excluderule PSUseBOMForUnicodeEncodedFile || exit 1

# , PSAvoidUsingWriteHost 