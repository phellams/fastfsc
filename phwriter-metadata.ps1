$phwriter_metadata_array = @(
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