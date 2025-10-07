# COMMON params
$source = "https://gitlab.com/phellams/fastfsc/-/blob/main/readme.md"
$phwriter_metadata_array = @(
    @{
        #CustomLogo  = $CustomLogo
        commandinfo = @{
            cmdlet      = "Get-FolderSizeFast";
            synopsis    = "Get-FolderSizeFast [-Path <String>] [-Recurse] [-Detailed] [-Format <String>] [-Help]";
            description = "This cmdlet calculates the size of a folder quickly by leveraging .NET methods. It supports recursion, progress display, and can output results in various formats including JSON and XML.";
            source      = ""
        }
        paramtable  = @(
            @{
                name        = "Path"
                param       = "p|Path"
                type        = "string"
                required    = $true
                description = "Specifies the path of the folder to calculate its size. Wildcards are supported."
                inline      = $false # Description on a new line
            },
            @{
                name        = "Detailed"
                param       = "d|Detailed"
                type        = "switch"
                required    = $false
                description = "Outputs detailed information about each file and folder processed."
                inline      = $false
            },
            @{
                name        = "format"
                param       = "f|Format"
                type        = "string"
                required    = $false
                description = "Specifies the output format. Supported formats are 'json' and 'xml'."
                inline      = $false
            }
            @{
                name        = "Help"
                param       = "h|Help"
                type        = "switch"
                required    = $false
                description = "Displays help information for the cmdlet."
                inline      = $false
            }
        )
        examples    = @(
            "Get-FolderSizeFast -Path 'C:\MyFolder' -Detailed",
            "Get-FolderSizeFast -Path 'C:\MyFolder' -format json",
            "Get-FolderSizeFast -Path 'C:\MyFolder' -format xml"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "Get-FolderSizeParallel";
            synopsis    = "Get-FolderSizeParallel [-Path <String>] [-Detailed] [-Format <String>] [-Help]";
            description = "This cmdlet calculates the size of a folder using parallel processing to enhance performance. It supports recursion, progress display, and can output results in various formats including JSON and XML.";
            source      = ""
        }
        paramtable  = @(
            @{
                name        = "Path"
                param       = "p|Path"
                type        = "string"
                required    = $true
                description = "Specifies the path of the folder to calculate its size. Wildcards are supported."
                inline      = $false # Description on a new line
            },
            @{
                name        = "Recurse"
                param       = "r|Recurse"
                type        = "switch"
                required    = $false
                description = "Indicates that the operation should process subdirectories recursively."
                inline      = $false
            },
            @{
                name        = "format"
                param       = "f|Format"
                type        = "string"
                required    = $false
                description = "Specifies the output format. Supported formats are 'json' and 'xml'."
                inline      = $false
            }
        )
        examples    = @(
            "Get-FolderSizeParallel -Path 'C:\MyFolder'",
            "Get-FolderSizeParallel -Path 'C:\MyFolder' -format json",
            "Get-FolderSizeParallel -Path 'C:\MyFolder' -format xml"
        )
    }
    @{
        commandinfo = @{
            cmdlet      = "Request-FolderReport";
            synopsis    = "Requst-FolderReport [-Path <String>] [-Format <String>] [-Help]";
            description = "This cmdlet generates a report of the size of a folder and can output results in various formats including JSON and XML.";
            source      = ""
        }
        paramtable  = @(
            @{
                name        = "Path"
                param       = "p|Path"
                type        = "string"
                required    = $true
                description = "Specifies the path of the folder to calculate its size. Wildcards are supported."
                inline      = $false # Description on a new line
            },
            @{
                name        = "Recurse"
                param       = "r|Recurse"
                type        = "switch"
                required    = $false
                description = "Indicates that the operation should process subdirectories recursively."
                inline      = $false
            },
            @{
                name        = "Detailed"
                param       = "d|Detailed"
                type        = "switch"
                required    = $false
                description = "Outputs detailed information about each file and folder processed."
                inline      = $false
            },
            @{
                name        = "format"
                param       = "f|Format"
                type        = "string"
                required    = $false
                description = "Specifies the output format. Supported formats are 'json' and 'xml'."
                inline      = $false
            }
        )
        examples    = @(
            "Request-FolderReport -Path C:\Users\User\Desktop\* -Format xml",
            "Request-FolderReport -Path C:\Users\User\Desktop\* -Format json",
            "Request-FolderReport -Path C:\Users\User\Desktop\*"
        )
    }
)