function Get-BestSizeUnit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [long]$Bytes
    )
    
    if ($Bytes -ge 1PB) {
        return "$([Math]::Round($Bytes / 1PB, 2)) PB"
    }
    elseif ($Bytes -ge 1TB) {
        return "$([Math]::Round($Bytes / 1TB, 2)) TB"
    }
    elseif ($Bytes -ge 1GB) {
        return "$([Math]::Round($Bytes / 1GB, 2)) GB"
    }
    elseif ($Bytes -ge 1MB) {
        return "$([Math]::Round($Bytes / 1MB, 2)) MB"
    }
    elseif ($Bytes -ge 1KB) {
        return "$([Math]::Round($Bytes / 1KB, 2)) KB"
    }
    else {
        return "$Bytes bytes"
    }
}