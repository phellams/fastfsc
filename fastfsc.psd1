@{
    RootModule         = 'fastfsc.psm1'
    ModuleVersion     = '0.2.8.0'
    GUID               = 'ccc9be26-17aa-4a86-8d5b-14d6d15def37'
    Author             = 'Garvey k. Snow'
    CompanyName        = 'Phellams'
    Copyright          = '(c) 2025 Garvey k. Snow. All rights reserved.'
    Description        = 'fastfsc is a PowerShell module designed for fast and efficient file system operations, including folder size calculations and streamlined query execution. It leverages parallel processing and optimized algorithms to handle large directories quickly.'
    HelpInfoURI        = 'https://github.com/phellams/fastfsc/blob/main/README.md'
    FunctionsToExport  = @(
        'Get-FolderSizeFast',
        'Get-FolderSizeParallel',
        'Get-BestSizeUnit'
    )
    CmdletsToExport    = @()
    VariablesToExport  = @()
    AliasesToExport    = @()
    PrivateData        = @{
        PSData = @{
            Tags             = @('FolderSize', 'speed', 'PowerShell', 'paralell', 'performance')
            ReleaseNotes     = @{
                # '1.2.1' = 'Initial release with New-PHWriter cmdlet for custom help formatting and enhanced layout.'
            }
            LicenseUri       = 'https://choosealicense.com/licenses/mit'
            ProjectUri       = 'https://gitlab.com/phellams/fastfsc.git'
            IconUri          = 'https://raw.githubusercontent.com/phellams/phellams-general-resources/main/logos/fastfsc/dist/png/fastfsc-logo-128x128.png'
            Prerelease       = 'prerelease'

            # CHOCOLATE ---------------------
            LicenseUrl       = 'https://choosealicense.com/licenses/mit'
            ProjectUrl       = 'https://github.com/phellams/ptoml'
            IconUrl          = 'https://raw.githubusercontent.com/phellams/phellams-general-resources/main/logos/fastfsc/dist/png/fastfsc-logo-128x128.png'
            Docsurl          = 'https://pages.gitlab.io/sgkens/ptoml'
            MailingListUrl   = 'https://github.com/phellams/fastfsc/issues'
            projectSourceUrl = 'https://github.com/phellams/fastfsc'
            bugTrackerUrl    = 'https://github.com/phellams/fastfsc/issues'
            Summary          = 'A PowerShell module for advanced file and folder searching with configuration management.'
            # CHOCOLATE ---------------------

        }        
    }
    RequiredModules    = @()
    RequiredAssemblies = @()
    FormatsToProcess   = @()
    TypesToProcess     = @()
    NestedModules      = @()
    ScriptsToProcess   = @()
}
