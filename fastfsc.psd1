@{
    RootModule         = 'fastfsc.psm1'
    ModuleVersion      = '1.2.5'
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
            ReleaseNotes     = @(
                'v0.1.0-prerelease - Initial release with Get-FolderSizeFast and Get-BestSizeUnit functions.'
            )
            LicenseUri       = 'https://choosealicense.com/licenses/mit'
            ProjectUri       = 'https://gitlab.com/phellams/fastfsc.git'
            IconUri          = 'https://raw.githubusercontent.com/phellams/phellams-general-resources/main/logos/fastfsc/dist/png/fastfsc-logo-128x128.png'
            Prerelease       = 'prerelease'

            # CHOCOLATE ---------------------
            LicenseUrl       = 'https://choosealicense.com/licenses/mit'
            ProjectUrl       = 'https://github.com/phellams/fastfsc'
            IconUrl          = 'https://raw.githubusercontent.com/phellams/phellams-general-resources/main/logos/phellams/dist/png/phellams-logo-128x128.png'
            Docsurl          = 'https://pages.gitlab.io/sgkens/fastfsc'
            MailingListUrl   = 'https://gitlab.com/phellams/fastfsc/issues'
            projectSourceUrl = 'https://gitlab.com/phellams/fastfsc'
            bugTrackerUrl    = 'https://gitlab.com/phellams/fastfsc/issues'
            Summary          = 'A PowerShell module for advanced file and folder searching with configuration management.'
            chocoDescription = @"
## Features

 * ⚡ **Ultra-fast performance** - 3-10x faster than `Get-ChildItem | Measure-Object`
 * 🔄 **Parallel processing** - Multi-threaded calculations for even better performance
 * 📊 **Multiple size units** - Automatic conversion to KB, MB, GB, TB, and PB
 * 🎯 **Smart unit selection** - `BestUnit` property shows the most readable format
 * 📈 **Detailed reporting** - File counts, folder counts, and calculation timing
 * 🛡️ **Error resilient** - Gracefully handles access denied and missing files
 * 🔗 **Pipeline support** - Works with PowerShell pipeline for batch operations
 * 🏢 **Enterprise ready** - Handles massive directory structures efficiently
"@
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
