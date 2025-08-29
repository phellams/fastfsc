# 🍹REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER


### **👻 Build Information:**
- **Pipeline ID**: $env:CI_PIPELINE_ID
- **Build Date**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')
- **Commit**: $env:CI_COMMIT_SHA

### 🌐 Package RepositoriesREPONAME_PLACE_HOLDER 

Phellams Modules are available in the following repositories:

#### 🧢 **Powershell Gallery**

```powershell 
Find-Module -Name REPONAME_PLACE_HOLDER -MinimumVersion ONLY_VERSION_PLACE_HOLDER PRERELEASE_PSGAL_PLACE_HOLDER  |
Install-module | 
Import-Module
```
#### 🧢 **Chocolatey**

```powershell
# fetch choco package
choco install REPONAME_PLACE_HOLDER --version=VERSION_AND_PRERELEASE_PLACE_HOLDER PRERELEASE_CHOCO_PLACE_HOLDER

# default location of downloaded package
# C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER
# Import module directly from chocolatey package
import-module -name C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER

# Copy to user profile location
Copy-Item -Path C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER -Destination $env:USERPROFILE\Documents\PowerShell\Modules
Import-Module -Name REPONAME_PLACE_HOLDER
```

#### 🧢 **Gitlab Packages**

```powershell
# Add nuget source
nuget add source --name GITGROUP_PLACE_HOLDER https://gitlab.com/GITGROUP_PLACE_HOLDER/nuget/v3/index.json

# Install from gitlab package
nuget install REPONAME_PLACE_HOLDER

# or install from source

nuget install REPONAME_PLACE_HOLDER -source https://gitlab.com/GITGROUP_PLACE_HOLDER/nuget/v3/index.json

# Default nuget install directory for nuget
# $path = $env:USERPROFILE\.nuget\packages #windows
# $path = $home\.nuget\packages #linux
import-module -name $path\REPONAME_PLACE_HOLDER
```

## 🚪 Build Artifactes

For all module output variations, you can simply extract the `.zip` files, or rename `.nupkg` files to `.zip`, then extract them using your preferred compression tool (e.g., **ZIP**, **PeaZip**, **7-Zip**, etc.). After extracting, navigate to the module directory (`cd`) and run Import-Module. Alternatively, you can use any of the methods mentioned above or below.

### Download and Installation

#### Nupkg

`REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg` 

🟦 Using `Install-Package`

```powershell
# Download the Package from the build artifact
Invoke-WebRequest -url "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/$($ENV:CI_JOB_ID)/artifacts/raw/dist/psgal/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg"

# Install the package using install-package
Install-Package -Name REPONAME_PLACE_HOLDER `
                -RequiredVersion VERSION_AND_PRERELEASE_PLACE_HOLDER `
                -Source '\path\to\download' `
                -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\REPONAME_PLACE_HOLDER" `
                -Force

# Import module into powershell session
Import-Module -Name REPONAME_PLACE_HOLDER
``` 

🟦 Using `nuget` from Gitlab packages

```powershell
Invoke-WebRequest -url "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/$($ENV:CI_JOB_ID)/artifacts/raw/dist/nuget/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" -OutFile "\path\to\download\REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg"

# default windows install location
# - %APPDATA%\NuGet\NuGet
nuget install REPONAME_PLACE_HOLDER -Version VERSION_AND_PRERELEASE_PLACE_HOLDER

Copy-Item -Path $env:APPDATA\NuGet\NuGet\REPONAME_PLACE_HOLDER -Destination $env:USERPROFILE\Documents\PowerShell\Modules

Import-Module -Name REPONAME_PLACE_HOLDER
```

🟦 Using `zip|7zp|pzip`

```powershell
# Zip
Expand-Archive -Path "\path\to\download\REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" `
               -DestinationPath "$env:USERPROFILE\Documents\PowerShell\Modules\REPONAME_PLACE_HOLDER"

# 7zip
7z.exe e "\path\to\download\REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" -o$env:USERPROFILE\Documents\PowerShell\Modules\REPONAME_PLACE_HOLDER

# Import the module
Import-Module REPONAME_PLACE_HOLDER
```

🟦 Using Choco

`REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-choco.nupkg`

```powershell
# Install from chocolatey nupkg file
# Elevated privileges required - install froms local source
# -
choco install REPONAME_PLACE_HOLDER --version="VERSION_AND_PRERELEASE_PLACE_HOLDER" --source="/download/path/to/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" PRERELEASE_CHOCO_PLACE_HOLDER

# import the module
Import-Module "C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER"

# or

Copy-Item -Path "C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER" -Destination $env:USERPROFILE\Documents\PowerShell\Modules\REPONAME_PLACE_HOLDER

# import the module
Import-Module REPONAME_PLACE_HOLDER
```