# Install Phylogenetics Software

$Root = "$HOME\PhyloApps"
$Downloads = "$Root\_downloads"

New-Item -ItemType Directory -Force -Path $Root | Out-Null
New-Item -ItemType Directory -Force -Path $Downloads | Out-Null

# Helper for downloading and unzipping
function Install-Zip($Name, $Url) {
    Write-Host "Installing $Name..." -ForegroundColor Cyan

    $Zip = "$Downloads\$Name.zip"

    Invoke-WebRequest -Uri $Url -OutFile $Zip

    # Extract directly into PhyloApps
    Expand-Archive -Path $Zip -DestinationPath $Root -Force
}

# BayesTraits
Install-Zip "BayesTraits" "https://www.evolution.reading.ac.uk/BayesTraitsV5.0.3/Files/BayesTraitsV5.0.3-Win64.zip"
Install-Zip "FabricPostProcessor" "https://www.evolution.reading.ac.uk/FabricPostProcessorV1.1.0/Files/FabricPostProcessor-Win64.zip"
Invoke-WebRequest -Uri "https://www.evolution.reading.ac.uk/BayesTraitsV5.0.3/Files/BayesTraitsV5.0.2-Manual.pdf" -OutFile "$Root\BayesTraitsV5.0.2-Manual.pdf"

# Move BayesTraits example files into an Examples folder
$BayesTraitsFolder = Get-ChildItem $Root -Directory |
    Where-Object { $_.Name -like "BayesTraits*" } |
    Select-Object -First 1
$ExamplesFolder = "$($BayesTraitsFolder.FullName)\Examples"
New-Item -ItemType Directory -Force -Path $ExamplesFolder | Out-Null
Get-ChildItem $BayesTraitsFolder.FullName -File |
    Where-Object { $_.Extension -in ".txt", ".trees" } |
    Move-Item -Destination $ExamplesFolder -Force

# Canopy
Install-Zip "Canopy" "https://github.com/ChrisOrgan/Canopy/releases/download/v1.0.0/Canopy-1.0.0-windows-x64.zip"

# MrBayes
Install-Zip "MrBayes" "https://github.com/NBISweden/MrBayes/releases/download/v3.2.7/MrBayes-3.2.7-WIN.zip"

# IQ-TREE
Install-Zip "IQ-TREE" "https://github.com/iqtree/iqtree2/releases/latest/download/iqtree-2.4.0-Windows.zip"

# Tracer
Install-Zip "Tracer" "https://github.com/beast-dev/tracer/releases/download/v1.7.2/Tracer.v1.7.2.zip"

# BEAST2
Install-Zip "BEAST2" "https://github.com/CompEvol/beast2/releases/download/v2.7.7/BEAST.v2.7.7.Windows.zip"

# Mesquite
Install-Zip "Mesquite" "https://github.com/MesquiteProject/MesquiteCore/releases/download/v4.03-build1133/Mesquite_4.03_build1133_Windows.zip"

# SeaView
Write-Host "Installing SeaView..." -ForegroundColor Cyan
Invoke-WebRequest `
    -Uri "https://doua.prabi.fr/software/seaview_data/seaview5.exe" `
    -OutFile "$Root\seaview5.exe"
& "C:\Program Files\7-Zip\7z.exe" x "$Root\seaview5.exe" "-o$Root\" -y
Remove-Item "$Root\seaview5.exe" -Force

# RevBayes
Write-Host "Installing RevBayes..." -ForegroundColor Cyan
$RevBayesUrl = "https://github.com/revbayes/revbayes/releases/download/v1.4.0/revbayes-v1.4.0-win64.tar.gz"
$RevBayesFile = "$Downloads\revbayes-v1.4.0-win64.tar.gz"
Invoke-WebRequest $RevBayesUrl -OutFile $RevBayesFile
& "$env:SystemRoot\System32\tar.exe" -xzf $RevBayesFile -C $Root

# Add folders containing executable files to USER path.
$FoldersToAdd = Get-ChildItem $Root -Recurse -File -Include *.exe,*.bat,*.cmd |
    Where-Object { $_.FullName -notlike "$Downloads*" } |
    ForEach-Object { $_.Directory.FullName } |
    Sort-Object -Unique

$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")

foreach ($Folder in $FoldersToAdd) {
    if ($CurrentPath -notlike "*$Folder*") {
        $CurrentPath = "$CurrentPath;$Folder"
        Write-Host "Added to user PATH: $Folder"
    }
}

[Environment]::SetEnvironmentVariable("Path", $CurrentPath, "User")

# Delete downloaded installer/archive files
Remove-Item -Recurse -Force $Downloads

Write-Host ""
Write-Host "Done. Installed apps are in: $Root" -ForegroundColor Green
Write-Host "Close and reopen PowerShell before testing commands from PATH." -ForegroundColor Yellow