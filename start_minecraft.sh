#!/bin/bash

# Exit immediately if a command exits with a non-zero status and handle pipes
set -eo pipefail

# --- Configuration ---
JAVA_LTS_VERSION="25"
# Use the script location as the root directory for portability
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
JAVA_HOME="${ROOT_DIR}/bin/runtime/temurin-${JAVA_LTS_VERSION}"
JAVA_EXTRACT_PATH="${ROOT_DIR}/bin/runtime/temurin-${JAVA_LTS_VERSION}-extract"
DATA_DIR="${ROOT_DIR}/data"

# Adoptium Download URL (Direct link to the archive without redirects is faster)
JAVA_URL_BASE="https://api.adoptium.net/v3/binary/latest/${JAVA_LTS_VERSION}/ga/linux/x64/jdk/hotspot/normal/eclipse?project=jdk"
JAVA_HOME_BIN="${JAVA_HOME}/bin/java"

# --- Functions ---

# Function to ensure directories exist (Using a single call for efficiency)
create_dirs() {
    echo "Ensuring necessary directories exist..."
    mkdir -p "${ROOT_DIR}/bin/runtime" "${ROOT_DIR}/cache" "${DATA_DIR}"
}

# Optimized Java Download and Extraction
download_and_extract_java() {
    echo "Java Runtime not found. Downloading the latest Adoptium LTS (Java ${JAVA_LTS_VERSION})..."

    rm -rf "${JAVA_EXTRACT_PATH}"
    mkdir -p "${JAVA_EXTRACT_PATH}"
    if ! curl -fsSL "${JAVA_URL_BASE}" | tar -xz -C "${JAVA_EXTRACT_PATH}" --strip-components=1; then
        rm -rf "${JAVA_EXTRACT_PATH}"
        echo "ERROR: Failed to download and extract Java. Check network connection and URL."
        exit 1
    fi
    if [ ! -f "${JAVA_EXTRACT_PATH}/bin/java" ]; then
        rm -rf "${JAVA_EXTRACT_PATH}"
        echo "ERROR: Java extraction completed, but java was not found."
        exit 1
    fi
    rm -rf "${JAVA_HOME}"
    mv "${JAVA_EXTRACT_PATH}" "${JAVA_HOME}"
    echo "Java Runtime extracted to ${JAVA_HOME}."
}

check_and_start() {
    if ! command -v minecraft-launcher >/dev/null 2>&1; then
        echo "ERROR: The 'minecraft-launcher' command was not found in PATH. Install it before running this script."
        return 1
    fi

    # 1. Check/Install Java
    if [ ! -f "${JAVA_HOME_BIN}" ]; then
        download_and_extract_java
    else
        echo "Java Runtime found."
    fi
    
    echo "Starting Minecraft Launcher in portable mode (WorkDir: ${DATA_DIR})..."
    
    # Set the JAVA_HOME environment variable for the launcher
    export JAVA_HOME="${JAVA_HOME}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
    
    # Run the system-installed launcher in the background (&)
    minecraft-launcher "--workDir" "${DATA_DIR}" &
    
    echo "Script finished. Check your desktop for the Minecraft Launcher window."
}

# --- Main Execution ---

create_dirs
check_and_start
