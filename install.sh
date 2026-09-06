#!/bin/bash
set -e

# PufferLib standalone installer
# Assumes Ubuntu 24.04 with CUDA 13.0 drivers already installed
apt-get update && apt-get install -y \
    curl git build-essential clang \
    htop gdb tmux ccache \
    libomp-dev libglfw3 libgl1-mesa-dev libgl1-mesa-dri xvfb xauth \
    libnccl2 libnccl-dev

git clone https://github.com/pufferai/pufferlib --branch 5.0

cd pufferlib
bash build.sh breakout --cu

echo "Done. Test your installation with: ./puffer train "
echo "Remote raylib: ssh in (no -X), then:"
echo "  source /path/to/puffertank/x11_ssh.sh   # or cd puffertank && ./docker.sh test"
echo "  ./puffer eval latest"
echo "  open the printed http://<this-machine>:6080/"
