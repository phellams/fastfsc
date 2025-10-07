using module cmdlets\Get-FolderSizeFast.psm1
using module cmdlets\Get-FolderSizeParallel.psm1
using module cmdlets\Request-FolderReport.psm1

$global:__fastfsc = @{
    rootpath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}

$module_config = @{
    function = @(
        'Get-FolderSizeFast', 
        'Get-FolderSizeParallel',
        'Request-FolderReport'
    )
    alias = @(
        'fscf',
        'fscp',
        'fscr'
    )
}

Export-ModuleMember @module_config