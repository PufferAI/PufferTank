#!/bin/bash

# Run this script as root. Prerequisites:
#   1. Disable secure boot in BIOS settings! Otherwise, NVIDIA drivers will not work.
#   2. apt-get update && apt-get install -y git
#   3. cd /home/puffer && git clone https://github.com/pufferai/puffertank

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

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Install Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin

usermod -aG docker puffer

grep -qxF "cd /home/puffer && bash docker.sh test" /etc/bash.bashrc || \
    echo "cd /home/puffer && bash docker.sh test" >> /etc/bash.bashrc

docker pull pufferai/puffertank:latest


# Install NVIDIA 535 drivers. They require unstable and experimental packages.
sed -i '/^deb .*main/ s/main/main contrib non-free/' /etc/apt/sources.list
UNSTABLE_REPO="deb http://deb.debian.org/debian/ unstable main contrib non-free"
EXPERIMENTAL_REPO="deb http://deb.debian.org/debian/ experimental main contrib non-free"
grep -qxF "$UNSTABLE_REPO" /etc/apt/sources.list || echo "$UNSTABLE_REPO" >> /etc/apt/sources.list
grep -qxF "$EXPERIMENTAL_REPO" /etc/apt/sources.list || echo "$EXPERIMENTAL_REPO" >> /etc/apt/sources.list

apt-get install -t experimental -y nvidia-driver

# Install container toolkit. Requires Debian11 (bullseye) repository
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey > /etc/apt/keyrings/nvidia-docker.key
echo "deb [signed-by=/etc/apt/keyrings/nvidia-docker.key] https://nvidia.github.io/nvidia-docker/debian11/nvidia-docker.list" > \
    /etc/apt/sources.list.d/nvidia-docker.list

apt-get update && apt-get install -y nvidia-container-toolkit
systemctl restart docker

# Instructions to complete the manual portion of installation 
echo -e "Installation complete.\nTo complete installation:\n\
1) Set passwords:\n\
   - passwd puffer\n\
   - passwd root\n\
2) Initialize Tailscale:\n\
   - tailscale up\n\
3) Reboot the machine."
