@echo off
title Minecraft 'portable' launcher.
color 02

:: Name: start_minecraft.bata
:: Purpose: A batch script that allows Minecraft to be run portable.
:: Author: https://github.com/hemiipatu
:: Revision/Commit History: https://github.com/hemiipatu/MinecraftPortable/commits/master

:setVariable
set startdir="%~dp0"
set startdir=%startdir:~0,-2%
call :dequote startdir

:setWorkDIR
set workdir=%startdir%\data

:setLockDIR
set lockdir=%startdir%\data\.minecraft

:setJavaHome
set java_home=%startdir%\bin\runtime\jdk-15.0.2\bin

:setPath
set path=%startdir%\bin\runtime\jdk-15.0.2\bin

:start
start "" "%startdir%\bin\MinecraftLauncher.exe" --workDir "%workdir%" --lockDir  "%lockdir%"