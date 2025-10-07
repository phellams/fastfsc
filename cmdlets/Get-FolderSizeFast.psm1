# # Add C# code inline to PowerShell
using module .\Get-BestSizeUnit.psm1
using module ..\libs\phwriter\phwriter.psm1

Add-Type -TypeDefinition @"
using System;
using System.IO;

public static class FastFolderSize
{
    public static long GetFolderSize(string folderPath)
    {
        if (!Directory.Exists(folderPath))
            throw new DirectoryNotFoundException("Directory not found: " + folderPath);
        
        return GetDirectorySize(new DirectoryInfo(folderPath));
    }
    
    public static long GetFolderSizeWithSubfolders(string folderPath, out int fileCount, out int folderCount)
    {
        fileCount = 0;
        folderCount = 0;
        
        if (!Directory.Exists(folderPath))
            throw new DirectoryNotFoundException("Directory not found: " + folderPath);
        
        return GetDirectorySizeDetailed(new DirectoryInfo(folderPath), ref fileCount, ref folderCount);
    }
    
    private static long GetDirectorySize(DirectoryInfo directory)
    {
        long size = 0;
        
        try
        {
            // Add file sizes
            FileInfo[] files = directory.GetFiles();
            foreach (FileInfo file in files)
            {
                try
                {
                    size += file.Length;
                }
                catch
                {
                    // Skip files we can't access
                }
            }
            
            // Add subdirectory sizes
            DirectoryInfo[] subdirectories = directory.GetDirectories();
            foreach (DirectoryInfo subdirectory in subdirectories)
            {
                try
                {
                    size += GetDirectorySize(subdirectory);
                }
                catch
                {
                    // Skip directories we can't access
                }
            }
        }
        catch
        {
            // Skip if we can't enumerate the directory
        }
        
        return size;
    }
    
    private static long GetDirectorySizeDetailed(DirectoryInfo directory, ref int fileCount, ref int folderCount)
    {
        long size = 0;
        
        try
        {
            folderCount++;
            
            // Add file sizes
            FileInfo[] files = directory.GetFiles();
            foreach (FileInfo file in files)
            {
                try
                {
                    size += file.Length;
                    fileCount++;
                }
                catch
                {
                    // Skip files we can't access
                }
            }
            
            // Add subdirectory sizes
            DirectoryInfo[] subdirectories = directory.GetDirectories();
            foreach (DirectoryInfo subdirectory in subdirectories)
            {
                try
                {
                    size += GetDirectorySizeDetailed(subdirectory, ref fileCount, ref folderCount);
                }
                catch
                {
                    // Skip directories we can't access
                }
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

    Quickly calculates the size of a folder in bytes, MB, and GB.
    
    .DESCRIPTION

    Get-FolderSizeFast is a PowerShell cmdlet that efficiently computes the total size of a specified folder, including all its subfolders and files. It provides options for detailed output, including file and folder counts, and supports error handling for inaccessible files or directories.

    .PARAMETER Path
    
    The path of the folder to calculate the size for. This parameter is mandatory and accepts pipeline input.   

    .PARAMETER Detailed
    If specified, the cmdlet returns additional details including file count, folder count, and calculation time.
    
    .PARAMETER json
    
    If specified, the output will be formatted as JSON.
    
    .EXAMPLE
    
    Get-FolderSizeFast -Path "C:\MyFolder"
    Calculates the size of "C:\MyFolder" and returns the size in bytes, MB, and GB.
    
    .EXAMPLE
    
    Get-FolderSizeFast -Path "C:\MyFolder" -Detailed
    Calculates the size of "C:\MyFolder" and returns detailed information including file count, folder count, and calculation time.
    .EXAMPLE
    
    "C:\MyFolder" | Get-FolderSizeFast -Detailed
    Uses pipeline input to calculate the size of "C:\MyFolder" with detailed output.
    
    .NOTES
#>

function Get-FolderSizeFast {
    [CmdletBinding()]
    [Alias('fscsize')]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $false)]
        [switch]$Detailed,

        [Parameter(Mandatory = $false)]
        [ValidateSet('json', 'xml')]                    
        [switch]$Format,

        [parameter(mandatory=$false)]
        [switch] $help
    )
    
    process {
        
        if ($help) {
            New-PHWriter -JsonFile "./libs/help_metadata/get-foldersizefast_phwriter_metadata.json"
            return;
        }
        if(!$Path -and !$Help) {
            Write-Error "Path parameter is required. Use -Help for usage information."
            return;
        }

        try {

            [console]::writeline("🤖≈ Generating fastfsc folder report on '$Path' ...")

            $resolvedPath = Resolve-Path $Path -ErrorAction Stop
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            if ($Detailed) {
                $fileCount = 0
                $folderCount = 0
                $size = [FastFolderSize]::GetFolderSizeWithSubfolders($resolvedPath.Path, [ref]$fileCount, [ref]$folderCount)
                
                $stopwatch.stop()
                
                [PSCustomObject]@{
                    Path        = $resolvedPath.Path
                    SizeBytes   = $size
                    SizeMB      = [Math]::Round($size / 1MB, 2)
                    SizeGB      = [Math]::Round($size / 1GB, 3)
                    FileCount   = $fileCount
                    FolderCount = $folderCount - 1  # Subtract 1 to exclude root folder
                    BestUnit          = Get-BestSizeUnit -Bytes $size
                    CalculationTimeMs = $stopwatch.ElapsedMilliseconds
                    CalculationTimeSec = [Math]::Round($stopwatch.Elapsed.TotalSeconds, 2)                              
                    CalculationTimeMin = [Math]::Round($stopwatch.Elapsed.TotalMinutes, 2)
                }
            }
            else {
                $size = [FastFolderSize]::GetFolderSize($resolvedPath.Path)
                
                [PSCustomObject]@{
                    Path      = $resolvedPath.Path
                    SizeBytes = $size
                    SizeMB    = [Math]::Round($size / 1MB, 2)
                    SizeGB    = [Math]::Round($size / 1GB, 3)
                }
            }
        }
        catch {
            Write-Error "🤖≈ Error calculating folder size for '$Path': $($_.Exception.Message)"
        }
    }
}