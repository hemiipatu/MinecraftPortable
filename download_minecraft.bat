@echo off
title Minecraft 'portable' downloader.
color 02

:: Name: download_minecraft.bat
:: Purpose: A batch script to download the official Minecraft.exe, Java JDK and format folders properly.
:: Author: https://github.com/hemiipatu
:: Revision/Commit History: https://github.com/hemiipatu/MinecraftPortable/commits/master

:: Create directories/folders required to run Minecraft as a portable application.
mkdir -p bin bin\runtime cache data

curl https://launcher.mojang.com/download/Minecraft.exe > bin/MinecraftLauncher.exe