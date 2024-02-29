#!/bin/bash

# cd /home/puffer

apt update -y

# Install kernel headers and build essential tools
apt-get install -y linux-headers-$(uname -r) build-essential dkms

# Docker
apt install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
usermod -aG docker puffer


# Add non-free repositories for NVIDIA drivers
sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list

# Define the experimental repository line
EXPERIMENTAL_REPO="deb http://deb.debian.org/debian/ experimental main non-free contrib"

# Check if the experimental repo line already exists in sources.list, add it if it doesn't
grep -qxF "$EXPERIMENTAL_REPO" /etc/apt/sources.list || echo "$EXPERIMENTAL_REPO" >> /etc/apt/sources.list


# Update the package list to reflect new repositories
apt-get update -y

# Install the NVIDIA driver using the Debian non-free repository
apt-get install -t experimental -y --no-install-recommends nvidia-driver=535

echo "Installation complete. Please reboot your system."

# Nvidia container (have to use Debian 11 bullseye for now)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey > /etc/apt/keyrings/nvidia-docker.key
curl -s -L https://nvidia.github.io/nvidia-docker/debian11/nvidia-docker.list > /etc/apt/sources.list.d/nvidia-docker.list
sed -i -e "s/^deb/deb \[signed-by=\/etc\/apt\/keyrings\/nvidia-docker.key\]/g" /etc/apt/sources.list.d/nvidia-docker.list

apt-get update && apt-get install -y nvidia-container-toolkit
systemctl restart docker



