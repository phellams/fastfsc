#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$modulename = $ModuleConfig.moduleName
#---CONFIG----------------------------

Invoke-ScriptAnalyzer -Path ./dist/$modulename `
                      -Recurse `
                      -severity warning `
                      -excluderule PSUseBOMForUnicodeEncodedFile || exit 1

# , PSAvoidUsingWriteHost 