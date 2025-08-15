Import-Module -Name .\fastfsc.psm1 -Force

# Compare performance
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$result1 = Get-FolderSizeFast -Path "G:\devspace"   
$time1 = $stopwatch.ElapsedMilliseconds
$stopwatch.Restart()

$result2 = Get-FolderSizeParallel -Path "G:\devspace"
$time2 = $stopwatch.ElapsedMilliseconds

Write-Host "Standard: $time1 ms vs Parallel: $time2 ms"