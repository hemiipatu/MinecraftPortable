# MinecraftPortable: Play on-the-go.
![GitHub issues](https://img.shields.io/github/issues/hemiipatu/minecraftportable?style=for-the-badge)
![GitHub closed issues](https://img.shields.io/github/issues-closed/hemiipatu/minecraftportable?style=for-the-badge)
[![License: GPL v3](https://img.shields.io/badge/license-gplv3-blue.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)
[![Maintenance](https://img.shields.io/badge/maintained%3f-yes-green.svg?style=for-the-badge)](https://github.com/hemiipatu/minecraftportable/graphs/commit-activity)
![GitHub contributors](https://img.shields.io/github/contributors/hemiipatu/minecraftportable?style=for-the-badge)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/hemiipatu/minecraftportable?style=for-the-badge)

&nbsp;

## What is MinecraftPortable
MinecraftPortable is a script which allows the official Minecraft client to be run as a portable application. It achieves this by storing all the games' data in folders it generates as opposed to _"%appdata%\.minecraft"_ on Windows or _"~/.minecraft"_ on Linux.

## Where and how are the game files saved
The script creates the following directories:
 - **_bin_** | Used to store _MinecraftLauncher.exe_ and is later used by the launcher itself.
 - **_bin\runtime_** | Used to store JavaJDK/JRE.
 - **_cache_** | Used by the launcher itself to cache game files - remains unused until first launch.
 - **_data_** | Use to store game data, containing what would otherwise be found in .minecraft.
  
## How to install
 - [Instructions for Windows]()
 - [Instructions for Linux]()

## Supporting MinecraftPortable project
If you are intrested in supporting the project you can:
 - [Submit Issues](https://github.com/hemiipatu/minecraftportable/issues/new)
