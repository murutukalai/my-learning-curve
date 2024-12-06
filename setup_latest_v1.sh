#!/bin/bash

set -euo pipefail  # Enable strict mode to catch errors early

# Global variables
DOWNLOAD_DIR="/tmp/setup_downloads"
LOG_FILE="./setup_error_$(date +%Y%m%d_%H%M%S).log"
SUCCESS_LOG="./setup_success_$(date +%Y%m%d_%H%M%S).log"
IGNORED_TOOLS=()

# Create download directory and ensure it exists
mkdir -p "$DOWNLOAD_DIR"

# Function to log errors
log_error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE"
}

# Function to log success
log_success() {
    echo "[SUCCESS] $1" | tee -a "$SUCCESS_LOG"
}

# Function to check if a tool is ignored
is_ignored() {
    for tool in "${IGNORED_TOOLS[@]}"; do
        if [[ "$1" == "$tool" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to install a tool if not already installed
install_tool() {
    TOOL_NAME=$1
    COMMAND=$2
    INSTALL_COMMAND=$3

    if is_ignored "$TOOL_NAME"; then
        echo "[INFO] Skipping installation of $TOOL_NAME as it's ignored."
        return
    fi

    if ! command -v "$COMMAND" &>/dev/null; then
        echo "[INFO] Installing $TOOL_NAME..."
        if eval "$INSTALL_COMMAND"; then
            log_success "$TOOL_NAME installed successfully."
        else
            log_error "Failed to install $TOOL_NAME."
        fi
    else
        echo "[INFO] $TOOL_NAME is already installed. Skipping."
        log_success "$TOOL_NAME was already installed."
    fi
}

# Parse flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -nti)
            shift
            IGNORED_TOOLS+=("$1")
            ;;
        *)
            echo "[ERROR] Unknown flag $1"
            exit 1
            ;;
    esac
    shift
done

# Installations
install_tool "tealdeer" "tldr" "sudo apt install tealdeer -y"
install_tool "Git" "git" "sudo apt install git-all -y"
install_tool "terminator" "terminator" "sudo apt install terminator -y"
install_tool "build-essential" "build-essential" "sudo apt install build-essential -y"

# Install Rust and related tools
install_tool "Rust" "rustup" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
install_tool "Just" "just" "cargo install just"
install_tool "SD" "sd" "cargo install sd"
install_tool "SQLX CLI" "sqlx" "cargo install sqlx-cli"
install_tool "Cargo Watch" "cargo-watch" "cargo install cargo-watch"
install_tool "XH" "xh" "cargo install xh --locked"
install_tool "Kondo" "kondo" "
    git clone https://github.com/tbillington/kondo.git \"$DOWNLOAD_DIR/kondo\" &&
    cargo install --path \"$DOWNLOAD_DIR/kondo/kondo\"
"

# Install Brave browser
install_tool "Brave Browser" "brave-browser" "
    sudo curl -fsSLo \"$DOWNLOAD_DIR/brave-browser-archive-keyring.gpg\" https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg &&
    sudo mv \"$DOWNLOAD_DIR/brave-browser-archive-keyring.gpg\" /usr/share/keyrings/ &&
    echo 'deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main' | sudo tee /etc/apt/sources.list.d/brave-browser-release.list &&
    sudo apt update -y &&
    sudo apt install brave-browser -y
"

# Install Deno
install_tool "deno" "deno" "curl -fsSL https://deno.land/install.sh | sh"

# Install htop
install_tool "htop" "htop" "sudo apt install htop -y"

# Install fast-cli
install_tool "fast-cli" "fast" "npm install --global fast-cli"

# Install Node.js, NVM, and Yarn
install_tool "NVM" "nvm" "
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash &&
    source ~/.bashrc
"
install_tool "Node.js" "node" "nvm install 20 && nvm use 20"
install_tool "Yarn" "yarn" "npm install --global yarn"

# Install scrcpy
install_tool "scrcpy" "scrcpy" "sudo apt install scrcpy -y"

# PostgreSQL
install_tool "PostgreSQL" "PostgreSQL" "sudo apt install postgresql -y"

# Install Docker Compose
install_tool "Docker Compose" "docker-compose" "
    sudo curl -L \"https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose &&
    sudo chmod +x /usr/local/bin/docker-compose
"

# Install Docker Desktop (Ensure latest version)
install_tool "Docker Desktop" "docker" "
    sudo apt-get remove docker docker-engine docker.io containerd runc -y &&  # Remove old versions if any
    curl -fsSL https://desktop.docker.com/linux/main/amd64/docker-desktop-4.21.1-amd64.deb -o \"$DOWNLOAD_DIR/docker-desktop.deb\" &&
    sudo dpkg -i \"$DOWNLOAD_DIR/docker-desktop.deb\" || sudo apt-get install -f -y
"

# Install Android Studio
install_tool "Android Studio" "studio.sh" "
    ANDROID_STUDIO_VERSION='2024.2.1.11' &&
    wget \"https://redirector.gvt1.com/edgedl/android/studio/ide-zips/$ANDROID_STUDIO_VERSION/android-studio-$ANDROID_STUDIO_VERSION-linux.tar.gz\" -O \"$DOWNLOAD_DIR/android-studio.tar.gz\" &&
    sudo tar -xvzf \"$DOWNLOAD_DIR/android-studio.tar.gz\" -C /opt/ &&
    echo '[Desktop Entry]
Version=1.0
Name=Android Studio
Comment=Android Studio IDE
Exec=/opt/android-studio/bin/studio.sh
Icon=/opt/android-studio/bin/studio.png
Terminal=false
Type=Application
Categories=Development;IDE;' | sudo tee /usr/share/applications/android-studio.desktop
"

# Install VS Code
install_tool "VS Code" "code" "
    curl -fsSL https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -o \"$DOWNLOAD_DIR/vscode.deb\" &&
    sudo dpkg -i \"$DOWNLOAD_DIR/vscode.deb\" || sudo apt-get install -f -y
"

# Cleanup
echo "[INFO] Cleaning up temporary downloads..."
rm -rf "$DOWNLOAD_DIR"

# Summary of Installed Tools
echo -e "\n===== Installation Summary ====="
if [[ -f "$SUCCESS_LOG" ]]; then
    echo "The following tools were successfully installed or already present:"
    cat "$SUCCESS_LOG"
else
    echo "No tools were installed."
fi

if [[ -f "$LOG_FILE" ]]; then
    echo -e "\nThe following errors occurred during installation:"
    cat "$LOG_FILE"
else
    echo -e "\nNo errors occurred."
fi

echo -e "\n[INFO] Setup completed successfully!"

