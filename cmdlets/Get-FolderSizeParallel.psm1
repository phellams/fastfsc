using module .\Get-BestSizeUnit.psm1
using module ../libs/phwriter/phwriter.psm1

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

<#
    .SYNOPSIS
        Calculates the size of a folder using parallel processing to enhance performance.

    .DESCRIPTION
        Calculates the size of a folder using parallel processing to enhance performance. This cmdlet processes files and subdirectories in parallel, which can significantly speed up the calculation process.

    .PARAMETER Path
        The path of the folder to calculate the size for. This parameter is mandatory and accepts pipeline input.

    .PARAMETER Format
        The format to use for the output. Valid options are 'json' and 'xml'. Default is 'json'.

    .PARAMETER Help
        If specified, the cmdlet returns help information for the command.

    .EXAMPLE
        Get-FolderSizeParallel -Path "C:\MyFolder"
        Calculates the size of "C:\MyFolder" and returns the size in bytes, MB, and GB.

    .EXAMPLE
        Get-FolderSizeParallel -Path "C:\MyFolder" -Detailed
        Calculates the size of "C:\MyFolder" and returns detailed information including file count, folder count, and calculation time.

    .EXAMPLE
        "C:\MyFolder" | Get-FolderSizeParallel -Detailed
        Uses pipeline input to calculate the size of "C:\MyFolder" with detailed output.

    .NOTES
    
#>

function Get-FolderSizeParallel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [ValidateSet('json', 'xml')]                    
        [string]$Format,
        [Parameter(Mandatory = $false)]
        [switch]$Help
    )
    process {

        if ($help) {
            New-PHWriter -JsonFile "./libs/help_metadata/Get-FolderSizeParallel_phwriter_metadata.json"
            return;
        }
        if(!$Path -and !$Help) {
            Write-Error "Path parameter is required. Use -Help for usage information."
            return;
        }

        try {
            $resolvedPath = Resolve-Path $Path -ErrorAction Stop
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            $size = [ParallelFolderSize]::GetFolderSizeParallel($resolvedPath.Path)
            
            $stopwatch.Stop()
            
            $folderstats = [PSCustomObject]@{
                Path              = $resolvedPath.Path
                SizeBytes         = $size
                SizeKB            = [Math]::Round($size / 1KB, 2)
                SizeMB            = [Math]::Round($size / 1MB, 2)
                SizeGB            = [Math]::Round($size / 1GB, 3)
                SizeTB            = [Math]::Round($size / 1TB, 4)
                SizePB            = [Math]::Round($size / 1PB, 5)
                BestUnit          = Get-BestSizeUnit -Bytes $size
                CalculationTimeMs = $stopwatch.ElapsedMilliseconds
                CalculationTimeSec = [Math]::Round($stopwatch.Elapsed.TotalSeconds, 2)                              
                CalculationTimeMin = [Math]::Round($stopwatch.Elapsed.TotalMinutes, 2)
            }
        }
        catch {
            [console]::writeline("Error: $($_.Exception.Message)")
        }
        if ($json) {
            return $folderstats | ConvertTo-Json -Depth 5
        } elseif($xml){
            return $folderstats | ConvertTo-Xml -NoTypeInformation -Depth 5
        } else {
            return $folderstats
        }
    }
}