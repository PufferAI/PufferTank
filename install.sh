#!/bin/bash
set -e

# PufferLib standalone installer
# Assumes Ubuntu 24.04 with CUDA 13.0 drivers already installed

apt-get update && apt-get install -y \
    curl git build-essential clang \
    htop gdb tmux ccache \
    libomp-dev libglfw3 libgl1-mesa-dev libgl1-mesa-dri xvfb xauth python3.12-dev \
    libnccl2 libnccl-dev

# python -> python3 symlink if missing
if ! command -v python &>/dev/null; then
    ln -s "$(which python3)" /usr/local/bin/python
fi

curl -LsSf https://astral.sh/uv/install.sh | sh
. "$HOME/.local/bin/env"
uv venv --python 3.12 venv
. venv/bin/activate

git clone https://github.com/pufferai/pufferlib --branch 4.0
cd pufferlib

CUDA_VER=$(nvcc --version 2>/dev/null | grep -oP 'release \K\d+\.\d+' | tr -d '.')
uv pip install torch --extra-index-url "https://download.pytorch.org/whl/cu${CUDA_VER:-130}"
uv pip install -e .

bash build.sh breakout
echo "Done. Test your installation with: puffer train breakout"
echo "Remote raylib: ssh in (no -X), then:"
echo "  source /path/to/puffertank/x11_ssh.sh   # or cd puffertank && ./docker.sh test"
echo "  puffer eval breakout --load-model-path latest"
echo "  open the printed http://<this-machine>:6080/"
