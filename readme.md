# **Fastfsc**

<a href="https://gitlab.com/phellams/fastfsc/readme"><img src="https://img.shields.io/badge/License-_mit-License?style=flat-square&labelColor=%23383838&color=%237A5ACF23CD5C5C
" alt="MIT License" /></a>
<img src="https://img.shields.io/gitlab/pipeline-status/phellams%2Ffastfsc?style=flat-square&logo=Gitlab&logoColor=%233478BD&labelColor=%232D2D34" alt="Build Status">
<img src="https://img.shields.io/codecov/c/gitlab/phellams/fastfsc?style=flat-square&logo=codecov&logoColor=%23E6746B&logoSize=auto&labelColor=%234A7A82
" alt="Build Status">
<img src="https://img.shields.io/gitlab/issues/open/phellams%2Ffastfsc?style=flat-square&logo=gitlab&logoColor=red&labelColor=%23ffffff&color=%236B8D29
" alt="gitlab issues">


A high-performance PowerShell module for calculating folder sizes using inline C# code. This module provides lightning-fast folder size calculations that are **3-10x** faster than native PowerShell methods, with support from bytes to petabytes.

## Features

- ⚡ **Ultra-fast performance** - 3-10x faster than `Get-ChildItem | Measure-Object`
- 🔄 **Parallel processing** - Multi-threaded calculations for even better performance
- 📊 **Multiple size units** - Automatic conversion to KB, MB, ▒GB, TB, and PB
- 🎯 **Smart unit selection** - `BestUnit` property shows the most readable format
- 📈 **Detailed reporting** - File counts, folder counts, and calculation timing
- 🛡️ **Error resilient** - Gracefully handles access denied and missing files
- 🔗 **Pipeline support** - Works with PowerShell pipeline for batch operations
- 🏢 **Enterprise ready** - Handles massive directory structures efficiently

## Installation

Phellams modules are available from [**PowerShell Gallery**](https://www.powershellgallery.com/packages/Fastfsc) and [**Chocolatey**](https://chocolatey.org/packages/fastfsc). you can access the raw assets via [**Gitlab Generic Assets**](https://gitlab.com/phellams/fastfsc/-/packages?orderBy=name&sort=desc&search[]=fastfsc) or nuget repository via [**Gitlab Packages**](https://gitlab.com/phellams/fastfsc/-/packages/?orderBy=name&sort=desc&search[]=fastfsc&type=NuGet).
|▓▓▓▓▒▒▒▒░░░|▓▓▓▓▒▒▒▒░░░|▓▓▓▓▒▒▒▒░░░|
|-|-|-|
|📦 PSGallery | <img src="https://img.shields.io/powershellgallery/v/fastfsc?label=version&style=flat-square&logoColor=blue&labelColor=23CD5C5C&color=%231E3D59" alt="powershellgallery"> | <img src="https://img.shields.io/powershellgallery/dt/fastfsc?style=flat-square&logoColor=blue&label=downloads&labelColor=23CD5C5C&color=%231E3D59" alt="powershellgallery-downloads"> |
|📦 Chocolatey | <img src="https://img.shields.io/chocolatey/v/fastfsc?label=version&include_prereleases&style=flat-square&logoColor=blue&labelColor=23CD5C5C&color=%231E3D59" alt="chocolatey"> | <img src="https://img.shields.io/chocolatey/dt/fastfsc?style=flat-square&logoColor=blue&label=downloads&include_prereleases&labelColor=23CD5C5C&color=%231E3D59" alt="chocolatey-downloads"> |
|💼 Releases/Tags | <img src="https://img.shields.io/gitlab/v/release/phellams%2Ffastfsc?include_prereleases&style=flat-square&logoColor=%2300B2A9&labelColor=%23CD5C5C&color=%231E3D59" alt="gitlab-release"> |<img src="https://img.shields.io/gitlab/v/tag/phellams%2Ffastfsc?include_prereleases&style=flat-square&logoColor=%&labelColor=%23CD5C5C&color=%231E3D59" alt="gitlab tags"> |

### Additinonal Installation Options:

🟢  **GitLab Packages using nuget**

See the [**packages**](https://gitlab.com/phellams/fastfsc/-/packages?orderBy=name&sort=desc&search[]=fastfsc) page for installation instructions.

For instructions on using nuget to source module packages from gitlb see [**Releases**](https://github.com/sgkens/fastfsc/releases) artifacts.

🟢 **Generic Assets**

The latest release artifacts can be downloaded from the [**Generic Assets**](https://gitlab.com/phellams/fastfsc/-/packages?orderBy=type&sort=desc&type=Generic) page.

🟢 **Git Clone**
> **Note**: This method is not recommended for production use.

```bash
# Clone the repository
git clone https://gitlab.com/phellams/fastfsc.git
cd fastfsc
import-module .\
```

## Quick Start

```powershell
# Import module from module directory
Import-Module -name Fastfsc

# Basic usage
Get-FolderSizeFast -Path "C:\Windows"

# Detailed information with file/folder counts
Get-FolderSizeFast -Path "C:\Program Files" -Detailed

# Parallel processing for large directories
Get-FolderSizeParallel -Path "D:\LargeDataset"

# Pipeline support
"C:\Users", "C:\Program Files" | Get-FolderSizeFast
```
## Functions

### ♾️ `Get-FolderSizeFast`

The main function for calculating folder sizes with optional detailed reporting.

**Parameters:**
- `Path` (Mandatory) - The folder path to analyze
- `Detailed` (Switch) - Include file counts, folder counts, and additional metrics

**Example Output:**
```
Path      : C:\Program Files
SizeBytes : 12884901888
SizeKB    : 12583892.5
SizeMB    : 12289.93
SizeGB    : 12.001
SizeTB    : 0.0117
SizePB    : 0.00001
BestUnit  : 12.0 GB
```

**Detailed Output:**
```
Path        : C:\Program Files
SizeBytes   : 12884901888
SizeKB      : 12583892.5
SizeMB      : 12289.93
SizeGB      : 12.001
SizeTB      : 0.0117
SizePB      : 0.00001
BestUnit    : 12.0 GB
FileCount   : 45234
FolderCount : 3421
```


### ♾️ `Get-FolderSizeParallel`

High-performance version using parallel processing for maximum speed on large directories.

**Parameters:**
- `Path` (Mandatory) - The folder path to analyze

**Example Output:**
```
Path             : D:\BigData
SizeBytes        : 5497558138880
SizeKB           : 5368708135
SizeMB           : 5242885.88
SizeGB           : 5120.005
SizeTB           : 5.0
SizePB           : 0.00488
BestUnit         : 5.0 TB
CalculationTimeMs: 2847
```

## Usage Examples

### Basic Folder Analysis
```powershell
# Analyze a single folder
$result = Get-FolderSizeFast -Path "C:\Users\Documents"
Write-Host "Documents folder is $($result.BestUnit)"
```

### Batch Analysis
```powershell
# Analyze multiple folders
$folders = @("C:\Program Files", "C:\Program Files (x86)", "C:\Windows")
$results = $folders | Get-FolderSizeFast | Sort-Object SizeBytes -Descending

$results | Format-Table Path, BestUnit, @{Name="Files";Expression={$_.FileCount}} -AutoSize
```

### Large Directory Performance Test
```powershell
# Compare performance
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$result1 = Get-FolderSizeFast -Path "D:\LargeFolder"
$time1 = $stopwatch.ElapsedMilliseconds
$stopwatch.Restart()

$result2 = Get-FolderSizeParallel -Path "D:\LargeFolder"
$time2 = $stopwatch.ElapsedMilliseconds

Write-Host "Standard: $time1 ms vs Parallel: $time2 ms"
```

### Enterprise Storage Analysis
```powershell
# Analyze network storage
$shares = @("\\server\share1", "\\server\share2", "\\server\archive")
$results = $shares | ForEach-Object {
    try {
        Get-FolderSizeParallel -Path $_
    } catch {
        Write-Warning "Could not access $_: $($_.Exception.Message)"
    }
}

$results | Sort-Object SizeBytes -Descending | Format-Table Path, BestUnit, CalculationTimeMs
```

### Finding Large Subdirectories
```powershell
# Find the largest subdirectories in a path
$parentPath = "C:\Users"
$subfolders = Get-ChildItem -Path $parentPath -Directory | ForEach-Object {
    Get-FolderSizeFast -Path $_.FullName
} | Sort-Object SizeBytes -Descending | Select-Object -First 10

$subfolders | Format-Table Path, BestUnit -AutoSize
```

## Performance Comparison

| Method                 | Time (Example) | Memory Usage | Notes                                                  |
| ---------------------- | -------------- | ------------ | ------------------------------------------------------ |
| Native PowerShell      | 45 seconds     | High         | `Get-ChildItem -Recurse \| Measure-Object Length -Sum` |
| Get-FolderSizeFast     | 12 seconds     | Low          | Optimized C# with error handling                       |
| Get-FolderSizeParallel | 6 seconds      | Medium       | Multi-threaded for large directories                   |

*Results vary based on directory structure, file count, and system specifications*

## Size Units Reference

| Unit | Bytes                 | Example Usage                   |
| ---- | --------------------- | ------------------------------- |
| KB   | 1,024                 | Small files and documents       |
| MB   | 1,048,576             | Photos, music files             |
| GB   | 1,073,741,824         | Movies, software installations  |
| TB   | 1,099,511,627,776     | Large datasets, media libraries |
| PB   | 1,125,899,906,842,624 | Enterprise data warehouses      |

The `BestUnit` property automatically selects the most appropriate unit for display.

## Error Handling

The module gracefully handles common issues:

- **Access Denied**: Skips files/folders without permissions and continues
- **Network Timeouts**: Continues processing other directories
- **Missing Paths**: Returns clear error messages
- **Long Path Names**: Handles Windows long path limitations
- **Locked Files**: Skips files in use by other processes

## System Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- .NET Framework 4.5+ (for Add-Type compilation)
- Appropriate file system permissions for target directories

## Troubleshooting

### Access Denied Errors

```powershell
# Run PowerShell as Administrator for system directories
# Or use specific credentials for network shares
```

### Slow Performance on Network Drives

```powershell
# Use the parallel version for better network performance
Get-FolderSizeParallel -Path "\\network\path"
```

### Memory Issues with Huge Directories

```powershell
# The C# implementation is memory efficient, but for extremely large
# directories (millions of files), consider processing subdirectories individually
```

## Contributing

This module is designed to be lightweight and fast. When contributing:
- Maintain backward compatibility
- Add unit tests for new features
- Document performance impacts
- Test with various directory structures

## License

This code is provided as-is for educational and practical use. Feel free to modify and distribute according to your needs.

## Changelog


<!--LINKS AND BADGES-->
[psgal-badge-version]: https://img.shields.io/powershellgallery/v/fastfsc?label=psgallery&style=flat-square&logoColor=blue&labelColor=23CD5C5C&color=%231E3D59
[psgal-badge-downloads]: <img src="https://img.shields.io/powershellgallery/dt/fastfsc?style=flat-square&logoColor=blue&label=downloads&labelColor=23CD5C5C&color=%231E3D59"alt="powershellgallery-downloads">
[choco-badge-version]:
[choco-badge-downloads]:

