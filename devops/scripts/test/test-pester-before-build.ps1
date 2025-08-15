#---CONFIG----------------------------

#---CONFIG----------------------------

# Pester Configration settings
# Invoke-Pester -CodeCoverage .\libs\*.psm1 -CodeCoverageOutputFile 'Coverage.xml' -CodeCoverageOutputFileFormat JaCoCo -script .\BT0-CI-Test-Pester.ps1 -PassThru

$pesterConfig = New-PesterConfiguration -hashtable @{
  CodeCoverage = @{ 
    Enabled               = $true
    OutputFormat          = 'JaCoCo'
    OutputPath            = 'coverage.xml'
    OutputEncoding        = 'utf8'
    CoveragePercentTarget = 85
    #path                  = @(".\cmdlets\*.psm1", ".\libs\*.psm1", ".\*.psm1")
    path                  = @(".\cmdlets\*.psm1", ".\*.psm1")
  }
  Run = @{
    #PassThru = $true
    #scriptblock = {'.\test\Test-Unit-Pester.ps1'}
    Path     = '.\tests\Test-Unit-Pester.ps1';
  }
}

Invoke-Pester -Configuration $pesterConfig

# dotnet tool install -g dotnet-reportgenerator-globaltool
#reportgenerator -reports:coverage.xml -targetdir:.\build\temp\coverage_visualizer --title:$Modulename --reporttypes:tmlInline_AzurePipelines ---tag:main