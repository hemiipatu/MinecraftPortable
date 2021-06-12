@echo off
title Minecraft 'portable' launcher.
color 02

:: Name: start_minecraft.bat
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
set java_home=%startdir%\bin\runtime\jdk-16.0.1\bin

:setPath
set path=%startdir%\bin\runtime\jdk-16.0.1\bin

:setCurl
set curl=%systemroot%\system32\curl.exe

:setTar
set tar=%systemroot%\system32\tar.exe

:checkExists
if exist bin\MinecraftLauncher.exe (
    goto start
) else (
    mkdir bin bin\runtime cache data && %curl% https://launcher.mojang.com/download/Minecraft.exe > bin/MinecraftLauncher.exe
)

else (
    %curl% -jkL -H "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/16.0.1+9/7147401fd7354114ac51ef3e1328291f/jdk-16.0.1_windows-x64_bin.zip > bin/runtime/jdk-16.0.1.zip
)

else (
    %tar% -xvf bin/runtime/jdk-16.0.1.zip -C bin/runtime/
)

:start
start "" "%startdir%\bin\MinecraftLauncher.exe" --workDir "%workdir%" --lockDir  "%lockdir%"
goto end

:deQuote
for /f "delims=" %%A in ('echo %%%1%%') do set %1=%%~A
goto setWorkDIR

:end
exit
