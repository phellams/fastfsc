using module ..\libs\phwriter\phwriter.psm1

<#
    .SYNOPSIS
    
    Generates a folder report using the Get-FolderSizeParallel or Get-FolderSizeFast function.

    .DESCRIPTION

    Generates a folder report using the Get-FolderSizeParallel or Get-FolderSizeFast function.

    .PARAMETER path

    The path of the folder to calculate the size for. This parameter is mandatory and accepts pipeline input.

    .PARAMETER format

    The format to use for the output. Valid options are 'json' and 'xml'. Default is 'json'.

    .PARAMETER help

    If specified, the cmdlet returns help information for the command.
#>

function Request-FolderReport {
    [cmdletbinding()]
    [alias('fscr')]
    param(
        [parameter(mandatory=$false)]
        [string[]]$path,
        [parameter(mandatory=$false)]
        [validateset('json', 'xml')]
        [string]$format,
        [parameter(mandatory=$false)]
        [switch]$help
    )

    process {
    
        Write-Host "🤖≈ GENERATING FASTFSC FOLDER REPORT..."

        if ($help) {
            New-Phwriter -JsonFile "$($global:__fastfsc.rootpath)\libs\help_metadata\request-folderreport_phwriter_metadata.json"
            return;
        }
        if (!$Path -and !$Help) {
            Write-Error "🤖≈ Path parameter is required. Use -Help for usage information."
            return;
        }
        

        [array]$folder_report_object = @()

        foreach($p in $path){
            if($paralell){
                $folder_report = Get-FolderSizeParallel -Path $p
            }else{
                $folder_report = Get-FolderSizeFast -Path $p -Detailed
            }
            $folder_report_object += $folder_report
        }

        if($format -eq 'json'){
            return $folder_report_object | ConvertTo-Json
        }elseif($format -eq 'xml'){
            return $folder_report_object | ConvertTo-Xml
        }else{
            return $folder_report_object
        }

    }
}