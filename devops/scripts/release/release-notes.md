# 🍹zypline.0.1.0-prerelease

### Release Notes:

### Features:

### Bug Fixes:

### Breaking Changes:

$Notes

## 🌐 Package Repositories

Phellams Modules are available in the following repositories:

---

#### Powershell Gallery

```powershell 
Find-Module -Name zypline -MinimumVersion 0.1.0 -AllowPrerelease  |
Install-module | 
Import-Module
```
#### **Chocolatey**

```powershell
# fetch choco package
choco install zypline --version=0.1.0-prerelease --prerelease prerelease

# default location of downloaded package
# C:\ProgramData\chocolatey\lib\zypline
# Import module directly from chocolatey package
import-module -name C:\ProgramData\chocolatey\lib\zypline

# Copy to user profile location
Copy-Item -Path C:\ProgramData\chocolatey\lib\zypline -Destination $env:USERPROFILE\Documents\PowerShell\Modules
Import-Module -Name zypline
```

#### **Gitlab** Packages

```powershell
# Add nuget source
nuget add source --name phellams https://gitlab.com/phellams/nuget/v3/index.json

# Install from gitlab package
nuget install zypline

# or install from source

nuget install zypline -source https://gitlab.com/phellams/nuget/v3/index.json

# Default nuget install directory for nuget
# $path = $env:USERPROFILE\.nuget\packages #windows
# $path = $home\.nuget\packages #linux
import-module -name $path\zypline
```

## 🚪 Build Artifactes

---
For all module output variations, you can simply extract the `.zip` files, or rename `.nupkg` files to `.zip`, then extract them using your preferred compression tool (e.g., **ZIP**, **PeaZip**, **7-Zip**, etc.). After extracting, navigate to the module directory (`cd`) and run Import-Module. Alternatively, you can use any of the methods mentioned above or below.

### Download and Installation

#### Nupkg

`zypline.0.1.0-prerelease.nupkg` 

🟦 Using `Install-Package`

```powershell
# Download the Package from the build artifact
Invoke-WebRequest -url "https://gitlab.com/phellams/zypline/-/jobs/$($ENV:CI_JOB_ID)/artifacts/raw/dist/psgal/zypline.0.1.0-prerelease.nupkg"

# Install the package using install-package
Install-Package -Name zypline `
                -RequiredVersion 0.1.0-prerelease `
                -Source '\path\to\download' `
                -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\zypline" `
                -Force

# Import module into powershell session
Import-Module $env:USERPROFILE\Documents\PowerShell\Modules\zypline -Force
``` 

🟦 Using `nuget` from Gitlab packages

```powershell
Invoke-WebRequest -url "https://gitlab.com/phellams/zypline/-/jobs/$($ENV:CI_JOB_ID)/artifacts/raw/dist/nuget/zypline.0.1.0-prerelease.nupkg" -OutFile "\path\to\download\zypline.0.1.0-prerelease.nupkg"

# default windows install location
# - %APPDATA%\NuGet\NuGet
nuget install zypline -Version 0.1.0-prerelease

Import-Module $env:USERPROFILE\Documents\PowerShell\Modules\zypline -Force
```

🟦 Using `zip|7zp|pzip`

```powershell
# Zip
Expand-Archive -Path "\path\to\download\zypline.0.1.0-prerelease.nupkg" `
               -DestinationPath "$env:USERPROFILE\Documents\PowerShell\Modules\zypline"

# 7zip
7z.exe e "\path\to\download\zypline.0.1.0-prerelease.nupkg" -o$env:USERPROFILE\Documents\PowerShell\Modules\zypline

# Import the module
Import-Module zypline -Force
```

🟦 Using Choco

`zypline.0.1.0-prerelease-choco.nupkg`

```powershell
# Install from chocolatey nupkg file
# Elevated privileges required - install froms local source
# -
choco install zypline --version="0.1.0-prerelease" --source="/download/path/to/zypline.0.1.0-prerelease.nupkg" --prerelease prerelease

# import the module
Import-Module "C:\ProgramData\chocolatey\lib\zypline" -Force
```
