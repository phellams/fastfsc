# PHWriter Metadata Generator

# ps1 script to generate phwriter metadata for cmdlets
# exports will be stored in json, phwriter cant load help data from json Using
# output file will be store per cmdlet to limit the size of the import time.

$moduleversion = '0.4.0-prerelease'
$modulename = 'fastfsc'
# custom log name is fastfsc in ascii art readable
$CustomLogo = @"
███████╗ █████╗ ████████╗████████╗███████╗███████╗
██╗   ██╗███████╗
██╔════╝╚══██╔══╝██╔════╝██╔════╝
████╗  ██║██╔════╝██╔════╝
██╔══╝  ██║██╔══╝  ██╔══╝
████╗  ██║██╔══╝  ██╔══╝
██║     ██║██║     ███████╗███████╗
╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝
"@

# Each object represents a cmdlet's help metadata which is then looped below and exported
# as cmdlet_<cmdletname>.json in the ./libs/help_data/ folder
$helpdata_array = @(
    @{
        Name        = $modulename;
        version     = $moduleversion
        Padding     = 1
        Indent      = 1
        #CustomLogo  = $CustomLogo
        CommandInfo = @{
            cmdlet      = "Get-FolderSizeFast";
            synopsis    = "Get-FolderSizeFast [-Path <String>] [-Recurse] [-Detailed] [-Format <String>] [-Help]";
            description = "This cmdlet calculates the size of a folder quickly by leveraging .NET methods. It supports recursion, progress display, and can output results in various formats including JSON and XML.";
        }
        ParamTable  = @(
            @{
                Name        = "Path"
                Param       = "p|Path"
                Type        = "string"
                required    = $true
                Description = "Specifies the path of the folder to calculate its size. Wildcards are supported."
                Inline      = $false # Description on a new line
            },
            @{
                Name        = "Recurse"
                Param       = "r|Recurse"
                Type        = "switch"
                required    = $false
                Description = "Indicates that the operation should process subdirectories recursively."
                Inline      = $false
            },
            @{
                Name        = "Detailed"
                Param       = "d|Detailed"
                Type        = "switch"
                required    = $false
                Description = "Outputs detailed information about each file and folder processed."
                Inline      = $false
            },
            @{
                Name        = "format"
                Param       = "f|Format"
                Type        = "string"
                required    = $false
                Description = "Specifies the output format. Supported formats are 'json' and 'xml'."
                Inline      = $false
            }
        )
        Examples    = @(
            "Get-FolderSizeFast -Path 'C:\MyFolder' -Detailed",
            "Get-FolderSizeFast -Path 'C:\MyFolder\*' -Recurse -ShowProgress",
            "Get-FolderSizeFast -Path 'C:\MyFolder' -Recurse -format json",
            "Get-FolderSizeFast -Path 'C:\MyFolder' -format xml"
        )
    },
    @{
        Name        = $modulename;
        version     = $moduleversion
        Padding     = 1
        Indent      = 1
        #CustomLogo  = $CustomLogo
        CommandInfo = @{
            cmdlet      = "Get-FolderSizeParallel";
            synopsis    = "Get-FolderSizeParallel [-Path <String>] [-Recurse] [-ShowProgress] [-Detailed] [-Format <String>] [-Help]";
            description = "This cmdlet calculates the size of a folder using parallel processing to enhance performance. It supports recursion, progress display, and can output results in various formats including JSON and XML.";
        }
        ParamTable  = @(
            @{
                Name        = "Path"
                Param       = "p|Path"
                Type        = "string"
                required    = $true
                Description = "Specifies the path of the folder to calculate its size. Wildcards are supported."
                Inline      = $false # Description on a new line
            },
            @{
                Name        = "Recurse"
                Param       = "r|Recurse"
                Type        = "switch"
                required    = $false
                Description = "Indicates that the operation should process subdirectories recursively."
                Inline      = $false
            },
            @{
                Name        = "Detailed"
                Param       = "d|Detailed"
                Type        = "switch"
                required    = $false
                Description = "Outputs detailed information about each file and folder processed."
                Inline      = $false
            },
            @{
                Name        = "format"
                Param       = "f|Format"
                Type        = "string"
                required    = $false
                Description = "Specifies the output format. Supported formats are 'json' and 'xml'."
                Inline      = $false
            }
        )
        Examples    = @(
            "Get-FolderSizeParallel -Path 'C:\MyFolder' -Detailed",
            "Get-FolderSizeParallel -Path 'C:\MyFolder\*' -Recurse -ShowProgress",
            "Get-FolderSizeParallel -Path 'C:\MyFolder' -Recurse -format json",
            "Get-FolderSizeParallel -Path 'C:\MyFolder' -format xml"
        )
    }
)

foreach ($helpdata in $helpdata_array) {
    $cmdlet_name = $helpdata.CommandInfo.cmdlet
    $json_output_path = "./libs/help_data/$($cmdlet_name)_phwriter_metadata.json"
    $helpdata | ConvertTo-Json -Depth 5 | Out-File -FilePath $json_output_path -Force -Encoding UTF8
    Write-Host "Generated help metadata for $cmdlet_name at $json_output_path"
}
