@echo off
title Minecraft 'portable' launcher.
color 02

:: Name:            start_minecraft.bat
:: Purpose:         A batch script that allows Minecraft to be run portable.
:: Author:          https://github.com/hemiipatu
:: Revision/Commit History: https://github.com/hemiipatu/MinecraftPortable/commits/master

:: --- Configuration ---
set "java_lts=25"
set "launcher_url=https://launcher.mojang.com/download/Minecraft.exe"
set "java_url=https://api.adoptium.net/v3/binary/latest/%java_lts%/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk"

:: Get the directory of the script and define root paths
:: %~dp0 is the drive and path, the / separator is usually included.
set "locationroot=%~dp0"
IF "%locationroot:~-1%" == "\" (
    set "locationroot=%locationroot:~0,-1%"
)
set "bindir=%locationroot%\bin"
set "runtimepath=%bindir%\runtime"
set "launcherpath=%bindir%\MinecraftLauncher.exe"
set "java_home=%runtimepath%\temurin-%java_lts%"
set "java_zip_path=%runtimepath%\temurin-%java_lts%.zip"
set "java_exe_path=%java_home%\bin\java.exe"
set "datadir=%locationroot%\data"

:: --- System Tools ---
:: Curl and Tar are available in modern Windows 10/11 (version 17063+)
set "curl=%systemroot%\system32\curl.exe"
set "tar=%systemroot%\system32\tar.exe"

:: --- Check and Install Launcher ---
IF NOT exist "%bindir%" mkdir "%bindir%"
IF NOT exist "%runtimepath%" mkdir "%runtimepath%"
IF NOT exist "%datadir%" mkdir "%datadir%"

echo Checking for Minecraft Launcher...
IF NOT exist "%launcherpath%" (
    echo Launcher not found. Downloading...

    :: Download Launcher
    "%curl%" --fail --location --silent --show-error "%launcher_url%" -o "%launcherpath%"
    IF errorlevel 1 (
        del "%launcherpath%" 2>nul
        echo ERROR: Failed to download Minecraft Launcher. Exiting.
        pause
        exit /b 1
    )
)

:: --- Check and Install Java Runtime ---
echo Checking for Java runtime...
IF NOT exist "%java_exe_path%" (
    echo Java runtime not found. Downloading and unzipping...
    
    :: Download Java
    "%curl%" --fail --location --silent --show-error "%java_url%" -o "%java_zip_path%"
    IF errorlevel 1 (
        del "%java_zip_path%" 2>nul
        echo ERROR: Failed to download Java Runtime. Exiting.
        pause
        exit /b 1
    )
    
    :: Unzip Java
    echo Unzipping Java...
    IF NOT exist "%java_home%" mkdir "%java_home%"
    "%tar%" -xf "%java_zip_path%" -C "%java_home%" --strip-components 1
    IF errorlevel 1 (
        del "%java_zip_path%" 2>nul
        echo ERROR: Failed to extract Java Runtime. Exiting.
        pause
        exit /b 1
    )
    
    :: Clean up zip file
    del "%java_zip_path%"
    
    IF NOT exist "%java_exe_path%" (
        echo ERROR: Failed to extract Java Runtime. Exiting.
        pause
        exit /b 1
    )
)

:: --- Start Minecraft ---
echo Starting Minecraft Launcher...
set "JAVA_HOME=%java_home%"
set "PATH=%JAVA_HOME%\bin;%PATH%"
start "" "%launcherpath%" --workDir "%datadir%" --lockDir "%datadir%\.minecraft"

:: --- End Script ---
exit /b 0
