# Minecraft Portable

> Run Minecraft anywhere without system-wide installation. All game data stored locally in portable directories.

![GitHub issues](https://img.shields.io/github/issues/hemiipatu/minecraftportable?style=for-the-badge)
![GitHub closed issues](https://img.shields.io/github/issues-closed/hemiipatu/minecraftportable?style=for-the-badge)
[![License: GPL v3](https://img.shields.io/badge/license-gplv3-blue.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)
[![Maintenance](https://img.shields.io/badge/maintained%3f-yes-green.svg?style=for-the-badge)](https://github.com/hemiipatu/minecraftportable/graphs/commit-activity)
![GitHub contributors](https://img.shields.io/github/contributors/hemiipatu/minecraftportable?style=for-the-badge)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/hemiipatu/minecraftportable?style=for-the-badge)

## 📋 Overview

**MinecraftPortable** allows the official Minecraft launcher to run as a completely portable application. Instead of installing Minecraft system-wide and storing data in `%appdata%` (Windows) or `~/.minecraft` (Linux), all game files and configuration are kept in self-contained local directories.

### What It Does

1. **Downloads the official Minecraft Launcher** automatically
2. **Provisions a bundled Java runtime** (Adoptium JDK 25 LTS) for guaranteed compatibility
3. **Stores all game data locally** in organized subdirectories
4. **Supports cross-platform execution** via PowerShell, batch, Python, and shell scripts
5. **Eliminates system-wide installation** requirements

## ⚙️ Requirements

### Windows
- **Windows 10 or 11**
- **PowerShell 5.0+** (built-in) OR **cmd.exe** OR **Python 3.6+**
- **Internet connection** for initial setup (downloads launcher and Java)
- **~1-2 GB free disk space** (launcher + Java runtime)

### Linux
- **Linux distribution** with `bash` and standard utilities
- **Minecraft Launcher** (system-installed via your package manager, or)
- **Python 3.6+** for automatic launcher download
- **~1-2 GB free disk space** for game data

## 🚀 Quick Start

### Windows Installation

#### Using PowerShell (Recommended)

1. **Clone or download** this repository:
   ```powershell
   git clone https://github.com/hemiipatu/MinecraftPortable.git
   cd MinecraftPortable
   ```

2. **Run the launcher:**
   ```powershell
   .\start_minecraft.ps1
   ```

   The script will:
   - Create necessary directories (`bin`, `runtime`, `data`)
   - Download Minecraft Launcher if missing
   - Download and unzip Java 25 LTS if missing
   - Launch the game with portable data storage

#### Using Batch File

1. **Navigate to the directory:**
   ```cmd
   cd C:\path\to\MinecraftPortable
   ```

2. **Run the batch launcher:**
   ```cmd
   start_minecraft.bat
   ```

#### Using Python

1. **Ensure Python 3.6+ is installed:**
   ```powershell
   python --version
   ```

2. **Run the Python launcher:**
   ```powershell
   python start_minecraft.py
   ```

### Linux Installation

#### Using Shell Script (System Launcher)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/hemiipatu/MinecraftPortable.git
   cd MinecraftPortable
   ```

2. **Make the script executable:**
   ```bash
   chmod +x start_minecraft.sh
   ```

3. **Run the launcher:**
   ```bash
   ./start_minecraft.sh
   ```

   Requires `minecraft-launcher` to be installed system-wide.

#### Using Python

1. **Make the script executable:**
   ```bash
   chmod +x start_minecraft.py
   ```

2. **Run the launcher:**
   ```bash
   python3 start_minecraft.py
   ```

## 🏗️ Architecture Diagram

```
User executes start script (PS1 / BAT / PY / SH)
        ↓
Script checks for required components
        ↓
Downloads Minecraft Launcher if missing
        ↓
Downloads Adoptium Java 25 LTS if missing
        ↓
Extracts Java to local runtime directory
        ↓
Sets JAVA_HOME environment variable
        ↓
Launches Minecraft with portable data path
        ↓
All game data stored in local /data directory
```

## 📁 Directory Structure

After first run, the following structure is created:

```
MinecraftPortable/
├── bin/
│   ├── MinecraftLauncher.exe           (Downloaded official launcher)
│   └── runtime/
│       └── temurin-25/                 (Extracted Java JDK)
│           ├── bin/
│           ├── lib/
│           └── ...
├── data/                               (Game data - replaces .minecraft)
│   ├── launcher_profiles.json
│   ├── versions/
│   ├── libraries/
│   ├── assets/
│   └── ...
├── cache/                              (Launcher cache)
├── start_minecraft.ps1                 (PowerShell launcher)
├── start_minecraft.bat                 (Batch launcher)
├── start_minecraft.py                  (Python launcher)
├── start_minecraft.sh                  (Shell launcher)
└── README.md
```

## 🔧 Components

### 1. **start_minecraft.ps1** - PowerShell Launcher
- **Platform:** Windows (PowerShell 5.0+)
- **Features:**
  - Downloads Minecraft Launcher to `bin/`
  - Downloads and extracts Adoptium Java 25 LTS
  - Launches game with `--workDir` pointing to portable `data/`
- **Best for:** Windows users with PowerShell

### 2. **start_minecraft.bat** - Batch Launcher
- **Platform:** Windows (cmd.exe)
- **Features:**
  - Alternative to PowerShell for Windows systems
  - Provides similar functionality to PowerShell version
- **Best for:** Legacy Windows systems or batch-only environments

### 3. **start_minecraft.py** - Python Launcher
- **Platform:** Windows and Linux
- **Features:**
  - Cross-platform launcher using Python 3.6+
  - Automatic platform detection
- **Best for:** Users with Python installed

### 4. **start_minecraft.sh** - Shell Launcher
- **Platform:** Linux
- **Features:**
  - Uses system-installed `minecraft-launcher`
  - Lightweight and efficient
- **Best for:** Linux users with launcher already installed

## ⚙️ Configuration

### Customizing Java Version

Edit the launcher script and modify the Java version variable:

**PowerShell (`start_minecraft.ps1`):**
```powershell
$JavaVersion = "25"  # Change to 21, 17, 11, etc.
```

**Python (`start_minecraft.py`):**
```python
JAVA_VERSION = "25"  # Change as needed
```

### Customizing Launcher URL

If you want to use a different launcher source:

**PowerShell:**
```powershell
$LauncherUrl = "https://your-custom-url/MinecraftLauncher.exe"
```

**Python:**
```python
LAUNCHER_URL = "https://your-custom-url/MinecraftLauncher.exe"
```

### Using a Custom Java Installation

Instead of auto-downloading Java, point to an existing installation:

1. Edit the relevant launcher script
2. Set `JAVA_HOME` environment variable to your Java directory
3. Comment out or remove the Java download/extraction section

## 🐛 Troubleshooting

### Launcher fails to download

**Problem:** Script exits with download error

**Solutions:**
1. **Check internet connection:**
   ```powershell
   Test-NetConnection -ComputerName api.adoptium.net -Port 443
   ```

2. **Verify URLs are accessible:**
   - Minecraft Launcher: https://launcher.mojang.com/download/Minecraft.exe
   - Adoptium API: https://api.adoptium.net/v3/binary/latest/25/ga

3. **Check disk space:**
   ```powershell
   Get-Volume | Select-Object DriveLetter, Size, SizeRemaining
   ```

4. **Run with administrator privileges** if on Windows

### Java extraction fails

**Problem:** Script stops after downloading Java archive

**Solutions:**
1. **Verify 7-Zip or built-in extraction:**
   - Ensure extraction tool has permissions
   - Check free disk space during extraction

2. **Manually extract Java:**
   ```powershell
   Expand-Archive -Path bin\runtime\temurin-25.zip -DestinationPath bin\runtime\
   ```

### Game won't launch

**Problem:** Minecraft Launcher opens but game fails to start

**Solutions:**
1. **Verify Java is extracted:**
   ```powershell
   Test-Path "bin\runtime\temurin-25\bin\java.exe"
   ```

2. **Check `data` directory permissions:**
   - Ensure read/write access to `data` folder
   - Run script as administrator if needed

3. **Review Minecraft Launcher logs:**
   - Check `data/.minecraft/launcher_log.txt`

4. **Clear launcher cache:**
   ```powershell
   Remove-Item -Recurse -Force data\launcher_packages
   Remove-Item -Recurse -Force data\launcher_profiles.json
   ```

### Permission denied on Linux

**Problem:** Script shows permission error when executing

**Solution:**
```bash
chmod +x start_minecraft.sh
chmod +x start_minecraft.py
./start_minecraft.sh
```

### Python script not found modules

**Problem:** ImportError when running Python launcher

**Solution:**
```bash
python3 -m pip install requests  # If custom downloader is used
python3 start_minecraft.py
```

## 🔐 Security

- **No system modification:** Portable installation makes no changes to Windows Registry or system files
- **Local storage:** All game data remains in the portable directory; no files written to `%appdata%`
- **Official sources:** Launcher and Java downloaded from official Mojang and Adoptium repositories
- **Standalone:** Game doesn't depend on system-wide Java installation, reducing compatibility issues

## 📝 File Reference

| File | Purpose | Platform |
|------|---------|----------|
| `start_minecraft.ps1` | Primary launcher | Windows (PowerShell) |
| `start_minecraft.bat` | Alternative launcher | Windows (cmd.exe) |
| `start_minecraft.py` | Cross-platform launcher | Windows & Linux (Python) |
| `start_minecraft.sh` | System launcher | Linux (Bash) |
| `LICENSE` | GPL v3 License | All |
| `README.md` | This file | All |

## 📄 License

This project is licensed under the **GNU General Public License v3.0**. See [LICENSE](LICENSE) file for details.

## 🤝 Contributing

To report issues or suggest improvements:

1. **Check existing issues:** [https://github.com/hemiipatu/MinecraftPortable/issues](https://github.com/hemiipatu/MinecraftPortable/issues)
2. **Submit a new issue:** [https://github.com/hemiipatu/MinecraftPortable/issues/new](https://github.com/hemiipatu/MinecraftPortable/issues/new)
3. **Provide details:**
   - Operating system and version
   - Launcher script used (`start_minecraft.ps1`, `start_minecraft.bat`, `start_minecraft.py`, or `start_minecraft.sh`)
   - Java version and installation details (if custom)
   - Full error message or description of unexpected behavior
   - Steps to reproduce the issue

## 🔗 Related Resources

- [Minecraft Official Launcher](https://www.minecraft.net/download)
- [Adoptium JDK Project](https://adoptium.net/)
- [Minecraft Wiki](https://minecraft.fandom.com/)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
- [Python Documentation](https://www.python.org/doc/)

---

**Last Updated:** November 2026
