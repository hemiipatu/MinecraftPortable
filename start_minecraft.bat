@echo off
title Minecraft 'portable' launcher.
color 02

:: Name:            start_minecraft.bat
:: Purpose:         A batch script that allows Minecraft to be run portable.
:: Author:          https://github.com/hemiipatu
:: Revision/Commit History: https://github.com/hemiipatu/MinecraftPortable/commits/master

:: --- Configuration ---
set "verljava=jdk-19.0.2"
set "versjava=19"
set "launcher_url=https://launcher.mojang.com/download/Minecraft.exe"
set "java_url=https://download.oracle.com/java/%versjava%/archive/%verljava%_windows-x64_bin.zip"

:: Get the directory of the script and define root paths
:: %~dp0 is the drive and path, the / separator is usually included.
set "locationroot=%~dp0"
IF "%locationroot:~-1%" == "\" (
    set "locationroot=%locationroot:~0,-1%"
)
set "bindir=%locationroot%\bin"
set "runtimepath=%bindir%\runtime"
set "launcherpath=%bindir%\MinecraftLauncher.exe"
set "java_zip_path=%runtimepath%\%verljava%.zip"
set "java_exe_path=%runtimepath%\%verljava%\bin\java.exe"
set "datadir=%locationroot%\data"

:: --- System Tools ---
:: Curl and Tar are available in modern Windows 10/11 (version 17063+)
set "curl=%systemroot%\system32\curl.exe"
set "tar=%systemroot%\system32\tar.exe"

:: --- Check and Install Launcher ---
echo Checking for Minecraft Launcher...
IF NOT exist "%launcherpath%" (
    echo Launcher not found. Creating directories and downloading...
    
    :: Use 'if not exist' to prevent errors if dir is already made
    IF NOT exist "%bindir%" mkdir "%bindir%"
    IF NOT exist "%runtimepath%" mkdir "%runtimepath%"
    IF NOT exist "%datadir%" mkdir "%datadir%"
    
    :: Download Launcher
    "%curl%" "%launcher_url%" -o "%launcherpath%"
    
    IF NOT exist "%launcherpath%" (
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
    "%curl%" -H "Cookie: oraclelicense=accept-securebackup-cookie" "%java_url%" -o "%java_zip_path%"
    
    IF NOT exist "%java_zip_path%" (
        echo ERROR: Failed to download Java Runtime. Exiting.
        pause
        exit /b 1
    )
    
    :: Unzip Java
    echo Unzipping Java...
    :: -C extracts to a directory, and the file contents will create the %verljava% folder inside
    "%tar%" -xvf "%java_zip_path%" -C "%runtimepath%"
    
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
start "" "%launcherpath%" --workDir "%datadir%" --lockDir "%datadir%\.minecraft"

:: --- End Script ---
exit /b 0
