#!/bin/bash

# Create directories for downloads and error logs
DOWNLOAD_DIR="/tmp/setup_downloads"
ERROR_LOG_DIR="/tmp/setup_errors"
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$ERROR_LOG_DIR"

# Timestamp for error logging
timestamp() {
    date +"%Y-%m-%d_%H-%M-%S"
}

# Log error and continue
log_error() {
    echo "[ERROR] $1"
    echo "$(timestamp): $1" >>"$ERROR_LOG_DIR/setup_error_$(timestamp).log"
}

# Check if a program is installed
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Flag handler for ignoring sections
IGNORE_SECTIONS=()
while getopts ":nti:" opt; do
  case $opt in
    i)
      IGNORE_SECTIONS+=("$OPTARG")
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

should_ignore() {
  local section="$1"
  [[ " ${IGNORE_SECTIONS[*]} " == *" $section "* ]]
}

# Update and upgrade system packages
if ! should_ignore "update"; then
  echo "Updating and upgrading the system..."
  sudo apt update -y && sudo apt upgrade -y || log_error "Failed to update/upgrade system."
fi

# Install curl
if ! should_ignore "curl" && ! is_installed curl; then
  echo "Installing curl..."
  sudo apt install curl -y || log_error "Failed to install curl."
fi

# Install Node Version Manager (nvm) and Node.js
if ! should_ignore "node"; then
  echo "Installing nvm and Node.js..."
  if ! is_installed nvm; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash || log_error "Failed to install nvm."
    source ~/.bashrc
  fi
  nvm install 20 || log_error "Failed to install Node.js 20."
  nvm use 20 || log_error "Failed to set Node.js version to 20."
  echo "Node.js version: $(node -v)"
  echo "npm version: $(npm -v)"
fi

# Fix npm if issues arise
if ! should_ignore "npm"; then
  echo "Checking npm installation..."
  if ! is_installed npm; then
    echo "npm installation failed. Reinstalling..."
    nvm install-latest-npm || log_error "Failed to reinstall npm."
  fi
fi

# Install Yarn
if ! should_ignore "yarn" && ! is_installed yarn; then
  echo "Installing Yarn..."
  npm install --global yarn || log_error "Failed to install Yarn."
fi

# Install Bun
if ! should_ignore "bun" && ! is_installed bun; then
  echo "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash || log_error "Failed to install Bun."
fi

# Install PostgreSQL
if ! should_ignore "postgresql" && ! is_installed psql; then
  echo "Installing PostgreSQL..."
  sudo apt install postgresql -y || log_error "Failed to install PostgreSQL."
fi

# Install Terminator
if ! should_ignore "terminator" && ! is_installed terminator; then
  echo "Installing Terminator..."
  sudo apt install terminator -y || log_error "Failed to install Terminator."
fi

# Install Deno
if ! should_ignore "deno" && ! is_installed deno; then
  echo "Installing Deno..."
  curl -fsSL https://deno.land/install.sh | sh || log_error "Failed to install Deno."
fi

# Install Visual Studio Code
if ! should_ignore "vscode" && ! is_installed code; then
  echo "Installing Visual Studio Code..."
  VS_CODE_FILE="$DOWNLOAD_DIR/vscode.deb"
  curl -fsSL https://code.visualstudio.com/sha/download?build=stable&os=linux-deb -o "$VS_CODE_FILE" || log_error "Failed to download Visual Studio Code."
  sudo dpkg -i "$VS_CODE_FILE" || log_error "Failed to install Visual Studio Code."
  sudo apt-get install -f -y || log_error "Failed to resolve dependencies for Visual Studio Code."
  rm "$VS_CODE_FILE"
fi

# Install Android Studio
if ! should_ignore "android-studio"; then
  ANDROID_STUDIO_VERSION="2024.2.1.11"
  ANDROID_STUDIO_FILE="$DOWNLOAD_DIR/android-studio.tar.gz"
  echo "Installing Android Studio..."
  wget "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/$ANDROID_STUDIO_VERSION/android-studio-$ANDROID_STUDIO_VERSION-linux.tar.gz" -O "$ANDROID_STUDIO_FILE" || log_error "Failed to download Android Studio."
  sudo tar -xvzf "$ANDROID_STUDIO_FILE" -C /opt/ || log_error "Failed to extract Android Studio."
  rm "$ANDROID_STUDIO_FILE"
  cat <<EOF | sudo tee /usr/share/applications/android-studio.desktop
[Desktop Entry]
Version=1.0
Name=Android Studio
Comment=Android Studio IDE
Exec=/opt/android-studio/bin/studio.sh
Icon=/opt/android-studio/bin/studio.png
Terminal=false
Type=Application
Categories=Development;IDE;
EOF
fi

# Install Docker Desktop
if ! should_ignore "docker-desktop" && ! is_installed docker; then
  echo "Installing Docker Desktop..."
  DOCKER_DESKTOP_FILE="$DOWNLOAD_DIR/docker-desktop.deb"
  curl -fsSL https://desktop.docker.com/linux/main/amd64/docker-desktop-4.21.1-amd64.deb -o "$DOCKER_DESKTOP_FILE" || log_error "Failed to download Docker Desktop."
  sudo dpkg -i "$DOCKER_DESKTOP_FILE" || log_error "Failed to install Docker Desktop."
  sudo apt-get install -f -y || log_error "Failed to resolve dependencies for Docker Desktop."
  rm "$DOCKER_DESKTOP_FILE"
fi

echo "All tasks completed. Check $ERROR_LOG_DIR for error logs, if any."

