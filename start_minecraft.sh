#!/bin/bash

# Exit immediately if a command exits with a non-zero status and handle pipes
set -eo pipefail

# --- Configuration ---
JAVA_VERS="19"
JAVA_VERL="jdk-19.0.2"
# Set PWD as the root directory for portability
ROOT_DIR="$(pwd)" 
JAVA_HOME="${ROOT_DIR}/bin/runtime/${JAVA_VERL}"
DATA_DIR="${ROOT_DIR}/data"

# Adoptium Download URL (Direct link to the archive without redirects is faster)
JAVA_URL_BASE="https://api.adoptium.net/v3/binary/latest/${JAVA_VERS}/ga/linux/x64/jdk/hotspot/normal/eclipse"
JAVA_HOME_BIN="${JAVA_HOME}/bin/java"

# --- Functions ---

# Function to ensure directories exist (Using a single call for efficiency)
create_dirs() {
    echo "Ensuring necessary directories exist..."
    mkdir -p "${ROOT_DIR}/bin/runtime" "${ROOT_DIR}/cache" "${DATA_DIR}"
}

# Optimized Java Download and Extraction
download_and_extract_java() {
    echo "Java Runtime not found. Downloading JDK ${JAVA_VERL}..."

    # Use curl with a direct pipe to tar. This eliminates the need to save 
    # the large .tar.gz archive to disk, significantly reducing I/O and time.
    # Flags: -f (fail), -s (silent), -L (follow redirects)
    if ! curl -fsSL "${JAVA_URL_BASE}" | tar -xz -C "${ROOT_DIR}/bin/runtime" --strip-components=1; then
        echo "ERROR: Failed to download and extract Java. Check network connection and URL."
        exit 1
    fi
    
    # After extraction, rename the directory to the expected JAVA_VERL
    # This assumes the extracted folder name is the first item in the runtime folder
    local extracted_folder
    # Find the newly extracted folder name (which will be the only other item)
    extracted_folder=$(find "${ROOT_DIR}/bin/runtime" -maxdepth 1 -type d ! -name runtime -print -quit)

    if [ -d "${extracted_folder}" ] && [ "${extracted_folder}" != "${JAVA_HOME}" ]; then
        mv "${extracted_folder}" "${JAVA_HOME}"
        echo "Java Runtime extracted and renamed to ${JAVA_VERL}."
    else
        echo "ERROR: Could not locate the newly extracted Java folder for renaming."
        exit 1
    fi
}

check_and_start() {
    # 1. Check/Install Java
    if [ ! -f "${JAVA_HOME_BIN}" ]; then
        download_and_extract_java
    else
        echo "Java Runtime found."
    fi
    
    # 2. Check Launcher (Informational warning, as we rely on system install)
    if ! command -v minecraft-launcher &> /dev/null; then
        echo "WARNING: The 'minecraft-launcher' command was not found in PATH. Ensure it's installed."
    fi

    echo "Starting Minecraft Launcher in portable mode (WorkDir: ${DATA_DIR})..."
    
    # Set the JAVA_HOME environment variable for the launcher
    export JAVA_HOME="${JAVA_HOME}"
    
    # Run the system-installed launcher in the background (&)
    minecraft-launcher "--workDir" "${DATA_DIR}" &
    
    echo "Script finished. Check your desktop for the Minecraft Launcher window."
}

# --- Main Execution ---

create_dirs
check_and_start
