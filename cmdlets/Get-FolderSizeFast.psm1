# Add C# code inline to PowerShell
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

# PowerShell wrapper functions
function Get-FolderSizeFast {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $false)]
        [switch]$Detailed,

        [Parameter(Mandatory = $false)]
        [ValidateSet('json', 'xml', 'text')]                    
        [switch]$json
    )
    
    process {
        try {
            $resolvedPath = Resolve-Path $Path -ErrorAction Stop
            
            if ($Detailed) {
                $fileCount = 0
                $folderCount = 0
                $size = [FastFolderSize]::GetFolderSizeWithSubfolders($resolvedPath.Path, [ref]$fileCount, [ref]$folderCount)
                
                [PSCustomObject]@{
                    Path        = $resolvedPath.Path
                    SizeBytes   = $size
                    SizeMB      = [Math]::Round($size / 1MB, 2)
                    SizeGB      = [Math]::Round($size / 1GB, 3)
                    FileCount   = $fileCount
                    FolderCount = $folderCount - 1  # Subtract 1 to exclude root folder
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
            Write-Error "Error calculating folder size for '$Path': $($_.Exception.Message)"
        }
    }
}
