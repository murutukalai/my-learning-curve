
#!/bin/bash

# Update system packages
sudo apt update -y
sudo apt upgrade -y

# Install curl
sudo apt install curl -y

# Install Node Version Manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Reload the shell to enable nvm 
source ~/.bashrc

# Install Node.js version 20
nvm install 20

# Ensure the correct Node.js version is being used
nvm use 20

# Check npm are properly installed
node -v
npm -v

# Install Yarn
npm install --global yarn

# Install Bun (JavaScript runtime like Node.js)
curl -fsSL https://bun.sh/install | bash

# Install PostgreSQL
sudo apt install postgresql -y

# Install Terminator
sudo apt install terminator -y

# Install Deno
curl -fsSL https://deno.land/install.sh | sh

# Install Tealdeer
sudo apt install tealdeer -y

# Install Git
sudo apt install git-all -y

# Install Rust and related tools
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
cargo install just
cargo install sd  # For copy the frontend to backend
cargo install sqlx-cli
cargo install cargo-watch
cargo install xh --locked  # Access URLs from the terminal
git clone https://github.com/tbillington/kondo.git
cargo install --path kondo/kondo

# Install Brave browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update -y
sudo apt install brave-browser -y

# Install performance monitoring tools
sudo apt install htop -y

# Install system info tool
sudo apt install neofetch -y

# Install network speed checker
npm install --global fast-cli

# Final update to ensure all packages are up-to-date
sudo apt update -y
sudo apt upgrade -y

sudo apt install git-all

# Update package index and install dependencies
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

# Add Docker GPG key and repository
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Installations
docker --version
docker-compose --version

#!/bin/bash

# Stop the script if any command fails
set -e

echo "Starting the installation of Docker Desktop and Android Studio..."

# Update the package list
echo "Updating package list..."
sudo apt-get update

# 1. Install Docker Desktop (CLI + Engine)
echo "Installing Docker Desktop prerequisites..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Adding Docker's repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Add the current user to the Docker group
echo "Adding current user to Docker group..."
sudo usermod -aG docker $USER
echo "Docker installation complete!"
echo "Please log out and log back in to apply Docker group changes."

# 2. Install Android Studio
echo "Installing Android Studio prerequisites..."
sudo apt-get install -y openjdk-17-jdk unzip

echo "Downloading Android Studio..."
ANDROID_STUDIO_URL=$(curl -s https://developer.android.com/studio | grep -oP 'https://dl.google.com/dl/android/studio/ide-zips/[^"]*linux.tar.gz' | head -1)
wget $ANDROID_STUDIO_URL -O android-studio.tar.gz

echo "Extracting Android Studio..."
sudo tar -xvzf android-studio.tar.gz -C /opt/

echo "Creating Android Studio launcher..."
sudo ln -s /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio

echo "Setting up desktop integration for Android Studio..."
cat <<EOF | sudo tee /usr/share/applications/android-studio.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Icon=/opt/android-studio/bin/studio.png
Exec="/opt/android-studio/bin/studio.sh" %f
Comment=Android Studio IDE
Categories=Development;IDE;
Terminal=false
StartupNotify=true
EOF

echo "Android Studio installation complete!"

# Clean up temporary files
echo "Cleaning up temporary files..."
rm android-studio.tar.gz

echo "Installation completed! Please restart your computer to apply change
