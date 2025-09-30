using module cmdlets\Get-BestSizeUnit.psm1
using module cmdlets\Get-FolderSizeFast.psm1
using module cmdlets\Get-FolderSizeParallel.psm1


$global:__fastfsc = @{}

$module_config = @{
    function = @(
        'Get-FolderSizeFast', 
        'Get-FolderSizeParallel',
        'Get-BestSizeUnit'
    )
    alias = @(
        'Get-FolderSizeFast', 
        'Get-FolderSizeParallel',
        'Get-BestSizeUnit'
    )
}

Export-ModuleMember @module_config