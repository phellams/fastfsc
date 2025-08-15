using module cmdlets\Get-FolderSizeFast.psm1
using module cmdlets\Get-FolderSizeParallel.psm1

$module_config = @{
    function = @('Get-FolderSizeFast', 'Get-FolderSizeParallel')
    alias = @('Get-FolderSizeFast', 'Get-FolderSizeParallel')
}

Export-ModuleMember @module_config