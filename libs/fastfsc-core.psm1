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
