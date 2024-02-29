#!/bin/bash

apt update -y

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

# Fix sources.list
cp sources.list /etc/apt/sources.list

# Install Tailscale
if ! command -v tailscale &> /dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
fi


cat "cd /home/puffer && bash docker.sh test" >> /etc/bash.bashrc

# Docker
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
    usermod -aG docker puffer
fi


# Define the experimental repository line
EXPERIMENTAL_REPO="deb http://deb.debian.org/debian/ experimental main non-free contrib"

# Check if the experimental repo line already exists in sources.list, add it if it doesn't
grep -qxF "$EXPERIMENTAL_REPO" /etc/apt/sources.list || echo "$EXPERIMENTAL_REPO" >> /etc/apt/sources.list


# Update the package list to reflect new repositories
apt-get update -y

# Install the NVIDIA driver using the Debian non-free repository
apt-get install -t experimental -y nvidia-driver

echo "Installation complete. Please reboot your system."

# Nvidia container (have to use Debian 11 bullseye for now)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey > /etc/apt/keyrings/nvidia-docker.key
curl -s -L https://nvidia.github.io/nvidia-docker/debian11/nvidia-docker.list > /etc/apt/sources.list.d/nvidia-docker.list
sed -i -e "s/^deb/deb \[signed-by=\/etc\/apt\/keyrings\/nvidia-docker.key\]/g" /etc/apt/sources.list.d/nvidia-docker.list

apt-get update && apt-get install -y nvidia-container-toolkit
systemctl restart docker


# Run passwd puffer or w/e the user is to set password.
# passwd root as well
