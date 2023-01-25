@echo off
title Minecraft 'portable' launcher.
color 02

:: Name: start_minecraft.bat
:: Purpose: A batch script that allows Minecraft to be run portable.
:: Author: https://github.com/hemiipatu
:: Revision/Commit History: https://github.com/hemiipatu/MinecraftPortable/commits/master

:setLocationRootDir
set location=%~dp0
set locationroot=%location%
IF "%location:~-1%" == "\" (
    set "locationroot=%location:~0,-1%" && goto setJavaDir
) ELSE goto setJavaDir

:setJavaDir
set versjava=19
set verljava=jdk-19.0.2
set locationjava=%locationroot%\bin\runtime\%verljava%\bin
    goto setCurl

:setCurl
set curl=%systemroot%\system32\curl.exe
    goto setTar

:setTar
set tar=%systemroot%\system32\tar.exe
    goto checkLauncherPrerequisites

:: Begin the process of checking prerequisites.
:checkLauncherPrerequisites
IF NOT exist %locationroot%\bin\MinecraftLauncher.exe (
    mkdir %locationroot%\bin %locationroot%\bin\runtime %locationroot%\cache %locationroot%\data && %curl% https://launcher.mojang.com/download/Minecraft.exe > %locationroot%/bin/MinecraftLauncher.exe
) ELSE goto checkJavaPrerequisites

:checkJavaPrerequisites
IF NOT exist %locationjava%\java.exe (
    %curl% -H "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/java/%versjava%/archive/%verljava%_windows-x64_bin.zip > %locationroot%/bin/runtime/%verljava%.zip && goto unzip
) ELSE goto start

:unzip
%tar% -xvf %locationroot%/bin/runtime/%verljava%.zip -C %locationroot%/bin/runtime/
goto start

:start
start "" "%locationroot%\bin\MinecraftLauncher.exe" --workDir "%locationroot%\data" --lockDir  "%locationroot%\data\.minecraft"
goto end

:end
exit
