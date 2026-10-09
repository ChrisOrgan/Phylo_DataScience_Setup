### 1. UPDATE POWERSHELL TO THE LATEST VERSION (V7+) & 7-Zip
# Install location: \Users\<USERNAME>\AppData\Local\Microsoft\WindowsApps\pwsh.exe
Write-Host "--- 1. Installing PowerShell 7 & NuGet ---" -ForegroundColor Cyan
winget uninstall --id Microsoft.PowerShell --exact --source winget --silent --accept-source-agreements
winget install --id Microsoft.PowerShell --source winget --exact --installer-type WIX
winget install --id 7zip.7zip --silent --accept-package-agreements --accept-source-agreements

# Ensure that the PowerShell folder and profile script file exist
$targetFolder = "$HOME\Documents\PowerShell"
$fileName     = "profile.ps1"
$fullFilePath = Join-Path -Path $targetFolder -ChildPath $fileName
# Create the folder if it doesn't exist
if (-not (Test-Path -Path $targetFolder)) {
    New-Item -Path $targetFolder -ItemType "Directory" -Force
}
# Create the empty file if it doesn't exist
if (-not (Test-Path -Path $fullFilePath)) {
    New-Item -Path $fullFilePath -ItemType "File"
    Write-Host "Empty script created at: $fullFilePath" -ForegroundColor Green
} else {
    Write-Host "File already exists!" -ForegroundColor Yellow

### 2. INSTALL MINIFORGE (CONDA/MAMBA) FOR PYTHON & UPDATE PATHS
Write-Host "--- 2. Installing Miniforge ---" -ForegroundColor Cyan
$miniforgeUrl = "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe"
$installerPath = "$env:TEMP\Miniforge3-Installer.exe"
$installDir = "$env:USERPROFILE\miniforge3"

Invoke-WebRequest -Uri $miniforgeUrl -OutFile $installerPath
Start-Process -FilePath $installerPath -ArgumentList "/S", "/InstallationType=JustMe", "/RegisterPython=0", "/D=$installDir" -Wait

### 3. SETUP CONDA
Write-Host "--- 3. Creating DataScience Environment with Mamba ---" -ForegroundColor Cyan
# Use the full path to mamba/conda to ensure it runs even if the path hasn't refreshed
$mambaExe = "$installDir\condabin\mamba.bat"

# Create the environment and install all packages at once
& $mambaExe create -n DataScience -y `
    git pip flake8 `
    ipython jupyterlab ipykernel pytest pytest-xdist `
    numpy pandas scipy scikit-learn statsmodels arviz`
    matplotlib seaborn bokeh dash `
    biopython

# Register the kernel so you can use this env in JupyterLab immediately
Write-Host "Registering Jupyter Kernel..." -ForegroundColor Gray
& "$installDir\envs\DataScience\python.exe" -m ipykernel install --user --name DataScience --display-name "Python 3 (DataScience)"

# Final Updates and Cleanup
Write-Host "Finalizing environment..." -ForegroundColor Gray
& $mambaExe update --all -n DataScience -y
& $mambaExe clean --all -y

# Append the auto-activation command to the profile
# May have to delete the auto conda init script in profile.ps1
'& "$HOME\miniforge3\shell\condabin\conda-hook.ps1"' | Add-Content -Path "$HOME\Documents\PowerShell\profile.ps1"
"conda activate DataScience" | Add-Content -Path "$HOME\Documents\PowerShell\profile.ps1"

### 4. INSTALL R (STANDALONE) AND POSITRON VIA WINGET
# This installs the official R distribution from CRAN and the Positron IDE
# Note: Positron installer may stall: terminate all "windows powershell" processes if it hangs
Write-Host "--- 4. Installing Standalone R and Positron IDE ---" -ForegroundColor Cyan
winget install --id RProject.R --source winget --accept-package-agreements
winget install --id Posit.Positron --source winget --accept-package-agreements

# Dynamically locate R and add to system path
$rRoot = Get-ChildItem -Path "C:\Program Files\R" | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
$rBinPath = Join-Path -Path $rRoot -ChildPath "bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::SetEnvironmentVariable("Path", "$currentPath;$rBinPath", "User")

# Setup R Libraries
Write-Host "--- Installing R Libraries ---" -ForegroundColor Cyan
$rScript = Get-ChildItem -Path "C:\Program Files\R" -Filter "Rscript.exe" -Recurse | Select-Object -First 1 -ExpandProperty FullName
$rCode = "options(repos=c(CRAN='https://cloud.r-project.org')); pkgs=c('box','testthat','tidyverse','MCMCglmm','ape', 'phytools','geiger','tidytree','deeptime','rogue','esquisse','BiocManager'); install.packages(pkgs); BiocManager::install(c('ggtree','treeio'), ask=F)"
& $rScript -e $rCode

### 5. INSTALL AND CONFIGURE OPENSSH
Write-Host "--- 5. Installing OpenSSH Client & Server ---" -ForegroundColor Cyan
winget install --id=Microsoft.OpenSSH.Preview -e --accept-package-agreements --accept-source-agreements
Set-Service -Name sshd -StartupType Automatic

### 6. INSTALL OHMYPOSH & POSHGIT
# Paths should be:
# 	C:\Users\USR_NAME\AppData\Local\oh-my-posh
# 	C:\Users\USR_NAME\AppData\Local\Programs\oh-my-posh\bin
#   C:\Users\USR_NAME\AppData\Local\Programs\oh-my-posh\themes
Write-Host "--- 4. Installing Shell Enhancements ---" -ForegroundColor Cyan
winget install JanDeDobbeleer.OhMyPosh -s winget
Install-Module -Name posh-git -Scope CurrentUser -Force

# Setup PowerShell Profile to load these by default
# Note: aliens & dracula are good themes
# Note: change font in windows terminal settings for icons
Add-Content -Path ~\Documents\PowerShell\profile.ps1 -Value 'oh-my-posh init pwsh | Invoke-Expression'
Write-Host "Setup Complete! Please restart your terminal for all changes to take effect." -ForegroundColor Green

