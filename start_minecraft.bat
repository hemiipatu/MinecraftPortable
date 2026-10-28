@echo off
title Minecraft 'portable' launcher.
color 02

:: Portable Minecraft launcher for Windows.

:: Configuration
set "java_lts=25"
set "launcher_url=https://launcher.mojang.com/download/Minecraft.exe"
set "java_url=https://api.adoptium.net/v3/binary/latest/%java_lts%/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk"

:: Paths relative to this script
set "locationroot=%~dp0"
IF "%locationroot:~-1%" == "\" (
    set "locationroot=%locationroot:~0,-1%"
)
set "bindir=%locationroot%\bin"
set "runtimepath=%bindir%\runtime"
set "launcherpath=%bindir%\MinecraftLauncher.exe"
set "java_home=%runtimepath%\temurin-%java_lts%"
set "java_extract_path=%runtimepath%\temurin-%java_lts%-extract"
set "java_zip_path=%runtimepath%\temurin-%java_lts%.zip"
set "java_exe_path=%java_home%\bin\java.exe"
set "datadir=%locationroot%\data"

:: Required Windows utilities
set "curl=%systemroot%\system32\curl.exe"
set "tar=%systemroot%\system32\tar.exe"

:: Download and install launcher
IF NOT exist "%bindir%" mkdir "%bindir%"
IF NOT exist "%runtimepath%" mkdir "%runtimepath%"
IF NOT exist "%datadir%" mkdir "%datadir%"

echo Checking for Minecraft Launcher...
IF NOT exist "%launcherpath%" (
    echo Launcher not found. Downloading...

    "%curl%" --fail --location --silent --show-error "%launcher_url%" -o "%launcherpath%"
    IF errorlevel 1 (
        del "%launcherpath%" 2>nul
        echo ERROR: Failed to download Minecraft Launcher. Exiting.
        pause
        exit /b 1
    )
)

:: Download and install Java runtime
echo Checking for Java runtime...
IF NOT exist "%java_exe_path%" (
    echo Java runtime not found. Downloading and unzipping...
    
    "%curl%" --fail --location --silent --show-error "%java_url%" -o "%java_zip_path%"
    IF errorlevel 1 (
        del "%java_zip_path%" 2>nul
        echo ERROR: Failed to download Java Runtime. Exiting.
        pause
        exit /b 1
    )
    
    echo Unzipping Java...
    IF exist "%java_extract_path%" rmdir /s /q "%java_extract_path%"
    mkdir "%java_extract_path%"
    "%tar%" -xf "%java_zip_path%" -C "%java_extract_path%" --strip-components 1
    IF errorlevel 1 (
        rmdir /s /q "%java_extract_path%" 2>nul
        del "%java_zip_path%" 2>nul
        echo ERROR: Failed to extract Java Runtime. Exiting.
        pause
        exit /b 1
    )

    IF NOT exist "%java_extract_path%\bin\java.exe" (
        rmdir /s /q "%java_extract_path%" 2>nul
        del "%java_zip_path%" 2>nul
        echo ERROR: Failed to verify Java Runtime. Exiting.
        pause
        exit /b 1
    )
    IF exist "%java_home%" rmdir /s /q "%java_home%"
    move "%java_extract_path%" "%java_home%" >nul
    IF errorlevel 1 (
        del "%java_zip_path%" 2>nul
        echo ERROR: Failed to install Java Runtime. Exiting.
        pause
        exit /b 1
    )
    
    del "%java_zip_path%"
    
    IF NOT exist "%java_exe_path%" (
        echo ERROR: Failed to extract Java Runtime. Exiting.
        pause
        exit /b 1
    )
)

:: Launch Minecraft
echo Starting Minecraft Launcher...
set "JAVA_HOME=%java_home%"
set "PATH=%JAVA_HOME%\bin;%PATH%"
start "" "%launcherpath%" --workDir "%datadir%" --lockDir "%datadir%\.minecraft"

exit /b 0
