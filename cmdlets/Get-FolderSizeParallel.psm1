using module .\Get-BestSizeUnit.psm1

Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Threading.Tasks;
using System.Collections.Concurrent;

public static class ParallelFolderSize
{
    public static long GetFolderSizeParallel(string folderPath)
    {
        if (!Directory.Exists(folderPath))
            throw new DirectoryNotFoundException("Directory not found: " + folderPath);
        
        return GetDirectorySizeParallel(new DirectoryInfo(folderPath));
    }
    
    private static long GetDirectorySizeParallel(DirectoryInfo directory)
    {
        long size = 0;
        
        try
        {
            // Get files in current directory
            FileInfo[] files = directory.GetFiles();
            
            // Calculate file sizes in parallel
            Parallel.ForEach(files, file =>
            {
                try
                {
                    System.Threading.Interlocked.Add(ref size, file.Length);
                }
                catch
                {
                    // Skip files we can't access
                }
            });
            
            // Get subdirectories
            DirectoryInfo[] subdirectories = directory.GetDirectories();
            
            // Process subdirectories in parallel
            var subSizes = new long[subdirectories.Length];
            Parallel.For(0, subdirectories.Length, i =>
            {
                try
                {
                    subSizes[i] = GetDirectorySizeParallel(subdirectories[i]);
                }
                catch
                {
                    subSizes[i] = 0;
                }
            });
            
            // Add all subdirectory sizes
            for (int i = 0; i < subSizes.Length; i++)
            {
                size += subSizes[i];
            }
        }
        catch
        {
            // Skip if we can't enumerate the directory
        }
        
        return size;
    }
}
"@

function Get-FolderSizeParallel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Path
    )
    
    process {
        try {
            $resolvedPath = Resolve-Path $Path -ErrorAction Stop
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            $size = [ParallelFolderSize]::GetFolderSizeParallel($resolvedPath.Path)
            
            $stopwatch.Stop()
            
            [PSCustomObject]@{
                Path              = $resolvedPath.Path
                SizeBytes         = $size
                SizeKB            = [Math]::Round($size / 1KB, 2)
                SizeMB            = [Math]::Round($size / 1MB, 2)
                SizeGB            = [Math]::Round($size / 1GB, 3)
                SizeTB            = [Math]::Round($size / 1TB, 4)
                SizePB            = [Math]::Round($size / 1PB, 5)
                BestUnit          = Get-BestSizeUnit -Bytes $size
                CalculationTimeMs = $stopwatch.ElapsedMilliseconds
            }
        }
        catch {
            Write-Error "Error calculating folder size for '$Path': $($_.Exception.Message)"
        }
    }
}