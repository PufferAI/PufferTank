#!/bin/bash

# Update packages
apt-get update -y

# Install essentials
apt-get install -y \
    linux-headers-$(uname -r) \
    build-essential \
    openssh-server \
    vim \
    dkms \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg

# Function to add a repo if not already present in /etc/apt/sources.list
add_repo() {
    REPO_URL="$1"
    REPO_ENTRY="$2 main contrib non-free"
    if ! grep -qRFe "$REPO_URL" /etc/apt/; then
        echo "$REPO_ENTRY" | tee -a /etc/apt/sources.list > /dev/null
    fi
}

# Modify /etc/apt/sources.list to include contrib and non-free for existing Debian entries
sed -i '/^deb .*main/ s/main/main contrib non-free/' /etc/apt/sources.list

# Add unstable and experimental repositories. Required for NVIDIA drivers
add_repo "http://deb.debian.org/debian/" "deb http://deb.debian.org/debian/ unstable"
add_repo "http://deb.debian.org/debian/" "deb http://deb.debian.org/debian/ experimental"

# Install Tailscale
if ! command -v tailscale &> /dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# Docker installation
DOCKER_GPG_KEY="/usr/share/keyrings/docker.gpg"
if [ ! -f "$DOCKER_GPG_KEY" ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o $DOCKER_GPG_KEY
fi

DOCKER_REPO="deb [arch=$(dpkg --print-architecture) signed-by=$DOCKER_GPG_KEY] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
DOCKER_REPO_FILE="/etc/apt/sources.list.d/docker.list"
if ! grep -qF -- "$DOCKER_REPO" "$DOCKER_REPO_FILE" 2>/dev/null; then
    echo "$DOCKER_REPO" | tee $DOCKER_REPO_FILE > /dev/null
fi

apt-get update -y
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin

# Add user to the Docker group
usermod -aG docker puffer

# Ensure docker.sh test script is run at login
if ! grep -qxF "cd /home/puffer && bash docker.sh test" /etc/bash.bashrc; then
    echo "cd /home/puffer && bash docker.sh test" >> /etc/bash.bashrc
fi

# Pull the latest Docker image
docker pull pufferai/puffertank:latest

# Install NVIDIA drivers
apt-get install -t experimental -y nvidia-driver

# NVIDIA container toolkit setup
NVIDIA_DOCKER_REPO="deb [signed-by=$NVIDIA_DOCKER_GPG_KEY] https://nvidia.github.io/nvidia-container-runtime/debian11 $(lsb_release -cs) stable"
NVIDIA_DOCKER_REPO_FILE="/etc/apt/sources.list.d/nvidia-docker.list"
if ! grep -qF -- "$NVIDIA_DOCKER_REPO" "$NVIDIA_DOCKER_REPO_FILE" 2>/dev/null; then
    echo "$NVIDIA_DOCKER_REPO" | tee $NVIDIA_DOCKER_REPO_FILE > /dev/null
fi

apt-get update && apt-get install -y nvidia-container-toolkit
systemctl restart docker

# Completion message with instructions
echo -e "Installation complete.\nTo complete installation:\n\
1) Set passwords:\n\
   - passwd puffer\n\
   - passwd root\n\
2) Initialize Tailscale:\n\
   - tailscale up\n\
3) Reboot the machine."
