import os
import sys
import platform
import subprocess
import shutil
import zipfile
import tarfile
from pathlib import Path

# Optional dependency: requests is needed only when a download is required.
try:
    import requests
except ImportError:
    requests = None

# Configuration
JAVA_LTS_VERSION = "25"

# Launcher configuration
LAUNCHER_URL_WIN = "https://launcher.mojang.com/download/Minecraft.exe"
LAUNCHER_URL_LINUX_TAR = "https://launcher.mojang.com/download/Minecraft.tar.gz"

# Paths
LOCATION_ROOT = Path(sys.argv[0]).resolve().parent

BIN_DIR = LOCATION_ROOT / "bin"
RUNTIME_PATH = BIN_DIR / "runtime"
DATA_DIR = LOCATION_ROOT / "data"

# Platform settings
SYSTEM = platform.system()

# Launcher paths
if SYSTEM == "Windows":
    LAUNCHER_URL = LAUNCHER_URL_WIN
    LAUNCHER_FILENAME = "MinecraftLauncher.exe"
    LAUNCHER_PATH = BIN_DIR / LAUNCHER_FILENAME
    LAUNCHER_DOWNLOAD_FILE = LAUNCHER_PATH
    
elif SYSTEM == "Darwin": # macOS
    # Install the .app bundle manually under bin before running this script.
    LAUNCHER_URL = None 
    LAUNCHER_FILENAME = "MinecraftLauncher.app"
    LAUNCHER_PATH = BIN_DIR / LAUNCHER_FILENAME
    
else: # Linux
    LAUNCHER_URL = LAUNCHER_URL_LINUX_TAR
    LAUNCHER_DOWNLOAD_FILE = BIN_DIR / "MinecraftLauncher.tar.gz"
    LAUNCHER_PATH = BIN_DIR / "minecraft-launcher"
    
# Java runtime paths
if SYSTEM == "Windows":
    JAVA_ARCHIVE_EXT = "zip"
    JAVA_API_OS = "windows"
    JAVA_EXE_SUFFIX = "java.exe"
elif SYSTEM == "Darwin":
    JAVA_ARCHIVE_EXT = "tar.gz"
    JAVA_API_OS = "mac"
    JAVA_EXE_SUFFIX = "java"
else: # Linux
    JAVA_ARCHIVE_EXT = "tar.gz"
    JAVA_API_OS = "linux"
    JAVA_EXE_SUFFIX = "java"

JAVA_URL = f"https://api.adoptium.net/v3/binary/latest/{JAVA_LTS_VERSION}/ga/{JAVA_API_OS}/x64/jdk/hotspot/normal/eclipse?project=jdk"
JAVA_ARCHIVE_PATH = RUNTIME_PATH / f"temurin-{JAVA_LTS_VERSION}.{JAVA_ARCHIVE_EXT}"
JAVA_DIR = RUNTIME_PATH / f"temurin-{JAVA_LTS_VERSION}"
JAVA_HOME = JAVA_DIR / "Contents" / "Home" if SYSTEM == "Darwin" else JAVA_DIR
JAVA_EXE_PATH = JAVA_HOME / "bin" / JAVA_EXE_SUFFIX

# Helpers
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
            r.raise_for_status()
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


def safe_extract_zip(archive_path: Path, destination: Path) -> None:
    root = destination.resolve()
    with zipfile.ZipFile(archive_path, 'r') as archive:
        for member in archive.infolist():
            target = (root / member.filename).resolve()
            try:
                within_root = os.path.commonpath((str(root), str(target))) == str(root)
            except ValueError:
                within_root = False
            if not within_root:
                raise RuntimeError(f"Unsafe ZIP member path: {member.filename}")
        archive.extractall(destination)


def safe_extract_tar(archive_path: Path, destination: Path) -> None:
    with tarfile.open(archive_path, 'r:gz') as archive:
        if hasattr(tarfile, "data_filter"):
            archive.extractall(destination, filter="data")
            return

        root = destination.resolve()
        for member in archive.getmembers():
            target = (root / member.name).resolve()
            try:
                within_root = os.path.commonpath((str(root), str(target))) == str(root)
            except ValueError:
                within_root = False
            if not within_root or member.issym() or member.islnk():
                raise RuntimeError(f"Unsafe TAR member: {member.name}")
        archive.extractall(destination)

# Download and install launcher
def check_and_install_launcher():
    """Checks for, downloads, and prepares the Minecraft Launcher."""
    print("\n## 🚀 Checking for Minecraft Launcher...")
    
    BIN_DIR.mkdir(parents=True, exist_ok=True)
    RUNTIME_PATH.mkdir(parents=True, exist_ok=True)
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    
    if LAUNCHER_PATH.exists():
        print("Minecraft Launcher found. Skipping download.")
        return

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
        
        print("Extracting Linux launcher...")
        try:
            safe_extract_tar(LAUNCHER_DOWNLOAD_FILE, BIN_DIR)
            
            LAUNCHER_DOWNLOAD_FILE.unlink()
            LAUNCHER_PATH.chmod(0o755)
        except Exception as e:
            print(f"ERROR: Failed to extract Linux Launcher. Error: {e}")
            sys.exit(1)
            
    if not LAUNCHER_PATH.exists():
        print("ERROR: Failed to verify Minecraft Launcher installation. Exiting.")
        sys.exit(1)

# Download and install Java runtime
def check_and_install_java():
    """Checks for, downloads, and extracts the platform-specific Java Runtime."""
    print("\n## ☕ Checking for Java Runtime...")
    if JAVA_EXE_PATH.exists():
        print("Java runtime found. Skipping download.")
        return
        
    print("Java runtime not found. Downloading and extracting...")

    if not download_file(JAVA_URL, JAVA_ARCHIVE_PATH):
        sys.exit(1)
            
    print(f"Extracting Adoptium LTS {JAVA_LTS_VERSION} JDK...")
    extract_path = RUNTIME_PATH / f"temurin-{JAVA_LTS_VERSION}-extract"
    try:
        if extract_path.exists():
            shutil.rmtree(extract_path)
        extract_path.mkdir(parents=True)

        if JAVA_ARCHIVE_EXT == "zip":
            safe_extract_zip(JAVA_ARCHIVE_PATH, extract_path)
        else:
            safe_extract_tar(JAVA_ARCHIVE_PATH, extract_path)

        extracted_root = next((path for path in extract_path.iterdir() if path.is_dir()), None)
        if extracted_root is None:
            raise RuntimeError("The JDK archive did not contain a top-level directory.")

        extracted_java = extracted_root / "Contents" / "Home" / "bin" / JAVA_EXE_SUFFIX if SYSTEM == "Darwin" else extracted_root / "bin" / JAVA_EXE_SUFFIX
        if not extracted_java.is_file():
            raise RuntimeError(f"Java executable not found in extracted archive: {extracted_java}")

        if JAVA_DIR.exists():
            shutil.rmtree(JAVA_DIR)
        extracted_root.replace(JAVA_DIR)
        
        JAVA_ARCHIVE_PATH.unlink()
        
    except Exception as e:
        shutil.rmtree(extract_path, ignore_errors=True)
        print(f"ERROR: Failed to extract Java Runtime. Error: {e}")
        sys.exit(1)
    finally:
        JAVA_ARCHIVE_PATH.unlink(missing_ok=True)
        shutil.rmtree(extract_path, ignore_errors=True)
        
    if not JAVA_EXE_PATH.exists():
        print("ERROR: Failed to verify extracted Java Runtime. Exiting.")
        sys.exit(1)
    
# Launch Minecraft
def start_minecraft():
    """Starts the Minecraft Launcher with the portable data directory."""
    print("\n## ▶️ Starting Minecraft Launcher...")
    
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
        env = os.environ.copy()
        env['JAVA_HOME'] = str(JAVA_HOME)
        env['PATH'] = str(JAVA_EXE_PATH.parent) + os.pathsep + env.get('PATH', '')

        subprocess.Popen(launcher_args, env=env)
        
    except FileNotFoundError:
        print(f"ERROR: Launcher executable not found at {LAUNCHER_PATH}. Exiting.")
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred while starting the launcher: {e}")
        sys.exit(1)

# Main
if __name__ == "__main__":
    check_and_install_launcher()
    check_and_install_java()
    start_minecraft()
    print("\n✅ Script finished. Minecraft should be launching.")
    sys.exit(0)
