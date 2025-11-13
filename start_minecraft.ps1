<#
.SYNOPSIS
    Sets up and launches Minecraft in a portable manner.
.DESCRIPTION
    This script downloads the Minecraft Launcher and a modern, open-source
    Java Development Kit (JDK), manages all files in local directories,
    and forces the Minecraft Launcher to store all game data in the local '.\data' folder.
.NOTES
    Uses Adoptium (Eclipse Temurin) for the Java runtime for licensing stability.
#>
[CmdletBinding()]
param()

# --- Configuration & Paths ---

# Use modern, stable Java 21 LTS (Long-Term Support)
$JavaVersion = "21"
# Adoptium API for reliable, open-source JDK download
$LauncherUrl = "https://launcher.mojang.com/download/Minecraft.exe"
$JavaApiUrl = "https://api.adoptium.net/v3/binary/latest/$($JavaVersion)/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk"

# Define Paths using $PSScriptRoot for reliability
$locationroot = $PSScriptRoot
$bindir = Join-Path $locationroot "bin"
$runtimepath = Join-Path $bindir "runtime"
$datadir = Join-Path $locationroot "data"
$launcherpath = Join-Path $bindir "MinecraftLauncher.exe"
$javaZipPath = Join-Path $runtimepath "java_runtime.zip"

# --- Functions ---

function New-Directory {
    param(
        [Parameter(Mandatory=$true)][string]$Path
    )
    if (-not (Test-Path $Path)) {
        Write-Verbose "Creating directory: $Path"
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Download-And-Verify {
    param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$OutputFile,
        [string]$Description = "File"
    )
    Write-Host "Downloading $($Description)..." -ForegroundColor Yellow
    try {
        # Use simple Get-Method for a clean download (aliased to iwr)
        Invoke-WebRequest -Uri $Uri -OutFile $OutputFile -MaximumRedirection 5 -UseBasicParsing
        if (-not (Test-Path $OutputFile)) {
            throw "Download failed: File not found at $($OutputFile)."
        }
        Write-Host "Download successful: $($Description)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to download $($Description). Details: $($_.Exception.Message)"
        return $false
    }
}

# --- Main Script Execution ---

# 1. Setup Directories
Write-Host "Setting up required directories..." -ForegroundColor Cyan
New-Directory -Path $bindir
New-Directory -Path $runtimepath
New-Directory -Path $datadir

# 2. Check and Install Launcher
Write-Host "`nChecking for Minecraft Launcher..." -ForegroundColor Cyan
if (-not (Test-Path $launcherpath)) {
    if (-not (Download-And-Verify -Uri $LauncherUrl -OutputFile $launcherpath -Description "Minecraft Launcher")) {
        Write-Host "Setup failed. Exiting." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Minecraft Launcher found." -ForegroundColor Green
}

# 3. Check and Install Java Runtime (JRE)
Write-Host "`nChecking for Java runtime..." -ForegroundColor Cyan

# Robust check: look for any 'java.exe' recursively inside the runtime folder.
$JavaExe = Get-ChildItem -Path $runtimepath -Filter 'java.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $JavaExe) {
    Write-Host "Java runtime not found. Downloading and unzipping..." -ForegroundColor Yellow

    # Download Java JRE
    if (-not (Download-And-Verify -Uri $JavaApiUrl -OutputFile $javaZipPath -Description "Java Runtime")) {
        Write-Host "Setup failed. Exiting." -ForegroundColor Red
        exit 1
    }

    # Unzip Java JRE
    Write-Host "Unzipping Java..." -ForegroundColor Yellow
    try {
        # Extract the ZIP directly into the runtime folder.
        Expand-Archive -Path $javaZipPath -DestinationPath $runtimepath -Force

        # Clean up zip file
        Remove-Item $javaZipPath -Force -ErrorAction SilentlyContinue

        # Final check for the executable path after extraction
        $JavaExe = Get-ChildItem -Path $runtimepath -Filter 'java.exe' -Recurse | Select-Object -First 1
        if (-not $JavaExe) {
            throw "Failed to find java.exe after extraction."
        }
        Write-Host "Java extraction successful." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to extract Java Runtime. Details: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Host "Java runtime found." -ForegroundColor Green
}

# 4. Start Minecraft
Write-Host "`nStarting Minecraft Launcher..." -ForegroundColor Green
$JavaExePath = $JavaExe.Directory.Parent.FullName # Get the path to the root Java folder (e.g., C:\...\jdk-21.0.1)

# Pass arguments to the launcher
$Arguments = @(
    "--workDir", "`"$datadir`"",
    "--lockDir", "`"$datadir\.minecraft`"",
    # OPTIONAL: Set the environment variable for the launcher to find the local Java
    "-Djava.home=`"$JavaExePath`""
)

Start-Process -FilePath $launcherpath -ArgumentList $Arguments -NoNewWindow
