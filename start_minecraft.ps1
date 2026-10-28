<#
.SYNOPSIS
    Sets up and launches Minecraft in a portable manner.
.DESCRIPTION
    Downloads the Minecraft Launcher and Adoptium JDK, and stores launcher and game data
    beneath the script directory.
.NOTES
    The Adoptium endpoint selects the latest patch for the configured LTS feature release.
#>
[CmdletBinding()]
param()

# Configuration

# Select the LTS feature release; Adoptium returns its latest patch.
$JavaVersion = "25"
$LauncherUrl = "https://launcher.mojang.com/download/Minecraft.exe"
$JavaApiUrl = "https://api.adoptium.net/v3/binary/latest/$($JavaVersion)/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk"

# Paths
$locationroot = $PSScriptRoot
$bindir = Join-Path $locationroot "bin"
$runtimepath = Join-Path $bindir "runtime"
$datadir = Join-Path $locationroot "data"
$launcherpath = Join-Path $bindir "MinecraftLauncher.exe"
$javaHome = Join-Path $runtimepath "temurin-$JavaVersion"
$javaExePath = Join-Path $javaHome "bin\java.exe"
$javaZipPath = Join-Path $runtimepath "temurin-$JavaVersion.zip"

# Helpers

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
        $curlPath = Join-Path $env:SystemRoot "System32\curl.exe"
        if (-not (Test-Path $curlPath -PathType Leaf)) {
            throw "curl.exe was not found at $curlPath."
        }

        & $curlPath --fail --location --silent --show-error --output $OutputFile $Uri
        if ($LASTEXITCODE -ne 0) {
            throw "curl.exe exited with code $LASTEXITCODE."
        }
        if (-not (Test-Path $OutputFile -PathType Leaf) -or (Get-Item $OutputFile).Length -eq 0) {
            throw "Download failed: File is missing or empty at $($OutputFile)."
        }
        Write-Host "Download successful: $($Description)" -ForegroundColor Green
        return $true
    }
    catch {
        Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue
        Write-Error "Failed to download $($Description). Details: $($_.Exception.Message)"
        return $false
    }
}

# Main

Write-Host "Setting up required directories..." -ForegroundColor Cyan
New-Directory -Path $bindir
New-Directory -Path $runtimepath
New-Directory -Path $datadir

# Download and install launcher.
Write-Host "`nChecking for Minecraft Launcher..." -ForegroundColor Cyan
if (-not (Test-Path $launcherpath)) {
    if (-not (Download-And-Verify -Uri $LauncherUrl -OutputFile $launcherpath -Description "Minecraft Launcher")) {
        Write-Host "Setup failed. Exiting." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Minecraft Launcher found." -ForegroundColor Green
}

# Download and install Java runtime.
Write-Host "`nChecking for Java runtime..." -ForegroundColor Cyan

if (-not (Test-Path $javaExePath -PathType Leaf)) {
    Write-Host "Java runtime not found. Downloading and unzipping..." -ForegroundColor Yellow

    if (-not (Download-And-Verify -Uri $JavaApiUrl -OutputFile $javaZipPath -Description "Java Runtime")) {
        Write-Host "Setup failed. Exiting." -ForegroundColor Red
        exit 1
    }

    Write-Host "Unzipping Java..." -ForegroundColor Yellow
    $extractPath = Join-Path $runtimepath "temurin-$JavaVersion-extract"
    try {
        Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
        New-Directory -Path $extractPath
        Expand-Archive -Path $javaZipPath -DestinationPath $extractPath -Force

        $extractedJavaExe = Get-ChildItem -Path $extractPath -Filter 'java.exe' -Recurse | Select-Object -First 1
        if (-not $extractedJavaExe) {
            throw "Failed to find java.exe in the downloaded archive."
        }
        $extractedJavaHome = $extractedJavaExe.Directory.Parent.FullName
        Remove-Item $javaHome -Recurse -Force -ErrorAction SilentlyContinue
        Move-Item $extractedJavaHome $javaHome
        Write-Host "Java extraction successful." -ForegroundColor Green

        Remove-Item $javaZipPath -Force -ErrorAction SilentlyContinue
        Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    catch {
        Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $javaZipPath -Force -ErrorAction SilentlyContinue
        Write-Error "Failed to extract Java Runtime. Details: $($_.Exception.Message)"
        exit 1
    }
}

if (Test-Path $javaExePath -PathType Leaf) {
    Write-Host "Java runtime found." -ForegroundColor Green
} else {
    Write-Error "Java runtime was not found at $javaExePath."
    exit 1
}

# Launch Minecraft.
Write-Host "`nStarting Minecraft Launcher..." -ForegroundColor Green
$env:JAVA_HOME = $javaHome
$env:PATH = "$(Join-Path $javaHome 'bin');$env:PATH"

$Arguments = @(
    "--workDir", "`"$datadir`"",
    "--lockDir", "`"$datadir\.minecraft`""
)

Start-Process -FilePath $launcherpath -ArgumentList $Arguments -NoNewWindow
