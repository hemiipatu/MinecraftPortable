import os
import sys
import platform
import subprocess
import zipfile
import tarfile
from pathlib import Path

# NOTE: This script requires the 'requests' library (pip install requests) for optimized downloads.
try:
    import requests
except ImportError:
    requests = None

# --- Configuration ---
VERL_JAVA = "jdk-19.0.2"
VERS_JAVA = "19"

# Official Download Links
LAUNCHER_URL_WIN = "https://launcher.mojang.com/download/Minecraft.exe"
LAUNCHER_URL_LINUX_TAR = "https://launcher.mojang.com/download/Minecraft.tar.gz"

# --- Define Paths ---
LOCATION_ROOT = Path(sys.argv[0]).resolve().parent

BIN_DIR = LOCATION_ROOT / "bin"
RUNTIME_PATH = BIN_DIR / "runtime"
DATA_DIR = LOCATION_ROOT / "data"

# Platform Detection
SYSTEM = platform.system()

# --- Launcher Setup ---
if SYSTEM == "Windows":
    LAUNCHER_URL = LAUNCHER_URL_WIN
    LAUNCHER_FILENAME = "MinecraftLauncher.exe"
    LAUNCHER_PATH = BIN_DIR / LAUNCHER_FILENAME
    LAUNCHER_DOWNLOAD_FILE = LAUNCHER_PATH
    
elif SYSTEM == "Darwin": # macOS
    # NOTE: Mac requires manual placement due to .dmg installer complexity.
    LAUNCHER_URL = None 
    LAUNCHER_FILENAME = "MinecraftLauncher.app"
    LAUNCHER_PATH = BIN_DIR / LAUNCHER_FILENAME
    
else: # Linux
    LAUNCHER_URL = LAUNCHER_URL_LINUX_TAR
    LAUNCHER_DOWNLOAD_FILE = BIN_DIR / "MinecraftLauncher.tar.gz"
    # The executable inside the extracted tarball is typically named 'minecraft-launcher'
    LAUNCHER_PATH = BIN_DIR / "minecraft-launcher"
    
# --- Java Setup ---
if SYSTEM == "Windows":
    JAVA_ARCHIVE_EXT = "zip"
    JAVA_ARCHIVE_OS = "windows-x64"
    JAVA_EXE_SUFFIX = "java.exe"
elif SYSTEM == "Darwin":
    JAVA_ARCHIVE_EXT = "tar.gz"
    JAVA_ARCHIVE_OS = "macos-x64"
    JAVA_EXE_SUFFIX = "java"
else: # Linux
    JAVA_ARCHIVE_EXT = "tar.gz"
    JAVA_ARCHIVE_OS = "linux-x64"
    JAVA_EXE_SUFFIX = "java"

JAVA_URL = f"https://download.oracle.com/java/{VERS_JAVA}/archive/{VERL_JAVA}_{JAVA_ARCHIVE_OS}_bin.{JAVA_ARCHIVE_EXT}"
JAVA_ARCHIVE_PATH = RUNTIME_PATH / f"{VERL_JAVA}.{JAVA_ARCHIVE_EXT}"
JAVA_DIR = RUNTIME_PATH / (f"{VERL_JAVA}.jdk" if SYSTEM == "Darwin" else VERL_JAVA)
JAVA_HOME = JAVA_DIR / "Contents" / "Home" if SYSTEM == "Darwin" else JAVA_DIR
JAVA_EXE_PATH = JAVA_HOME / "bin" / JAVA_EXE_SUFFIX

# --- Optimized Helper Function ---
def download_file(url: str, destination: Path, headers=None) -> bool:
    """Optimized download using requests, streaming to handle large files efficiently."""
    if requests is None:
        print("ERROR: Downloading requires the 'requests' package. Install it with: pip install requests")
        return False

    filename = destination.name
    temporary_path = destination.with_name(f"{destination.name}.part")
    print(f"Downloading {filename}...")
    try:
        with requests.get(url, headers=headers or {}, stream=True, timeout=30) as r:
            r.raise_for_status() # Raise exception for bad status codes (4xx or 5xx)
            with open(temporary_path, 'wb') as f:
                for chunk in r.iter_content(chunk_size=1024 * 1024):
                    if chunk:
                        f.write(chunk)
        if temporary_path.stat().st_size == 0:
            raise ValueError("The server returned an empty file.")
        os.replace(temporary_path, destination)
        return True
    except requests.exceptions.RequestException as e:
        print(f"ERROR: Failed to download {filename}. Error: {e}")
        return False
    except Exception as e:
        print(f"ERROR: An unexpected error occurred during download: {e}")
        return False
    finally:
        temporary_path.unlink(missing_ok=True)

# --- Core Functions ---
def check_and_install_launcher():
    """Checks for, downloads, and prepares the Minecraft Launcher."""
    print("\n## 🚀 Checking for Minecraft Launcher...")
    
    # 1. Ensure directories exist
    BIN_DIR.mkdir(parents=True, exist_ok=True)
    RUNTIME_PATH.mkdir(parents=True, exist_ok=True)
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    
    # 2. Check if Launcher exists
    if LAUNCHER_PATH.exists():
        print("Minecraft Launcher found. Skipping download.")
        return

    # 3. Handle Download and Installation
    print("Launcher not found. Attempting to install...")

    if SYSTEM == "Windows":
        if not download_file(LAUNCHER_URL, LAUNCHER_DOWNLOAD_FILE):
            sys.exit(1)
            
    elif SYSTEM == "Darwin":
        print(f"❌ ERROR: Official macOS installer is not portable.")
        print(f"Please manually download the launcher and drag the **{LAUNCHER_FILENAME}** bundle into the '{BIN_DIR}' directory.")
        sys.exit(1)

    elif SYSTEM == "Linux":
        if not download_file(LAUNCHER_URL, LAUNCHER_DOWNLOAD_FILE):
            sys.exit(1)
        
        # Extract Linux Tarball
        print("Extracting Linux launcher...")
        try:
            with tarfile.open(LAUNCHER_DOWNLOAD_FILE, 'r:gz') as tar_ref:
                # Extract to BIN_DIR
                tar_ref.extractall(BIN_DIR)
            
            LAUNCHER_DOWNLOAD_FILE.unlink() # Delete the archive file
            LAUNCHER_PATH.chmod(0o755) # Ensure the executable is runnable
        except Exception as e:
            print(f"ERROR: Failed to extract Linux Launcher. Error: {e}")
            sys.exit(1)
            
    if not LAUNCHER_PATH.exists():
        print("ERROR: Failed to verify Minecraft Launcher installation. Exiting.")
        sys.exit(1)

# --- Java Installation (Optimized) ---
def check_and_install_java():
    """Checks for, downloads, and extracts the platform-specific Java Runtime."""
    print("\n## ☕ Checking for Java Runtime...")
    if JAVA_EXE_PATH.exists():
        print("Java runtime found. Skipping download.")
        return
        
    print("Java runtime not found. Downloading and extracting...")

    # Oracle requires a specific cookie to accept license (Header for archive downloads)
    oracle_headers = {"Cookie": "oraclelicense=accept-securebackup-cookie"}
    if not download_file(JAVA_URL, JAVA_ARCHIVE_PATH, headers=oracle_headers):
        sys.exit(1)
            
    # Extract Java
    print(f"Extracting Java {JAVA_ARCHIVE_EXT}...")
    try:
        # Extract the archive into the runtime directory.
        if JAVA_ARCHIVE_EXT == "zip":
            with zipfile.ZipFile(JAVA_ARCHIVE_PATH, 'r') as zip_ref:
                # Extract all contents
                zip_ref.extractall(RUNTIME_PATH)
        else: # tar.gz (Mac/Linux)
            with tarfile.open(JAVA_ARCHIVE_PATH, 'r:gz') as tar_ref:
                tar_ref.extractall(RUNTIME_PATH)
        
        JAVA_ARCHIVE_PATH.unlink() # Delete the archive file
        
    except Exception as e:
        print(f"ERROR: Failed to extract Java Runtime. Error: {e}")
        sys.exit(1)
        
    if not JAVA_EXE_PATH.exists():
        print("ERROR: Failed to verify extracted Java Runtime. Exiting.")
        sys.exit(1)
    
# --- Start Minecraft ---
def start_minecraft():
    """Starts the Minecraft Launcher with the portable data directory."""
    print("\n## ▶️ Starting Minecraft Launcher...")
    
    # Arguments to force the launcher to use our portable data directory
    # Note: Path objects are converted to strings automatically in subprocess calls
    launcher_args = [
        "open", "-a", str(LAUNCHER_PATH), "--args",
        "--workDir", str(DATA_DIR),
        "--lockDir", str(DATA_DIR / ".minecraft")
    ] if SYSTEM == "Darwin" else [
        str(LAUNCHER_PATH),
        "--workDir", str(DATA_DIR),
        "--lockDir", str(DATA_DIR / ".minecraft")
    ]
    
    try:
        # Set the JAVA_HOME environment variable to our portable Java path.
        env = os.environ.copy()
        env['JAVA_HOME'] = str(JAVA_HOME)
        env['PATH'] = str(JAVA_EXE_PATH.parent) + os.pathsep + env.get('PATH', '')

        # Use subprocess.Popen for non-blocking start (script exits while launcher runs)
        subprocess.Popen(launcher_args, env=env)
        
    except FileNotFoundError:
        print(f"ERROR: Launcher executable not found at {LAUNCHER_PATH}. Exiting.")
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred while starting the launcher: {e}")
        sys.exit(1)

# --- Main Execution ---
if __name__ == "__main__":
    check_and_install_launcher()
    check_and_install_java()
    start_minecraft()
    print("\n✅ Script finished. Minecraft should be launching.")
    sys.exit(0)
