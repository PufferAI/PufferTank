#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# PufferLib 5.0 standalone installer (pure CUDA C).
# Raylib: GLFW + Mesa. NetHack/fast-nle: cmake, bison, flex, ncurses.
# python3-dev is only headers for fast-nle's pybind11 cmake probe, not a Python env.
apt-get update && apt-get install -y \
    curl git build-essential clang ccache pkg-config unzip \
    libomp-dev libglfw3 libgl1-mesa-dev libgl1-mesa-dri xvfb xauth \
    cmake bison flex libncurses-dev libbz2-dev python3-dev ffmpeg

# fast-nle requires CMake >= 3.28; Ubuntu 24.04 is fine, older distros need a bump.
cmake_ver=$(cmake --version | awk 'NR==1{print $3}')
cmake_ok=$(printf '%s\n' "$cmake_ver" | awk -F. '{
    if ($1 > 3 || ($1 == 3 && $2 >= 28)) print "yes"; else print "no"
}')
if [ "$cmake_ok" != "yes" ]; then
    echo "CMake $cmake_ver is too old for NetHack; installing 3.31..."
    curl -sL https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-linux-x86_64.tar.gz \
        | tar -xz -C /usr/local --strip-components=1
fi

if [ ! -d pufferlib ]; then
    git clone --filter=blob:none --single-branch --branch 5.0 https://github.com/pufferai/pufferlib
fi

if command -v nvcc >/dev/null; then
    # CUDA devel images already ship held NCCL packages; don't try to upgrade them.
    if ! dpkg -s libnccl2 >/dev/null 2>&1 || ! dpkg -s libnccl-dev >/dev/null 2>&1; then
        apt-get install -y libnccl2 libnccl-dev
    fi
    echo "Installed and ready to puff up your training!"
else
    echo "NVCC not found. PufferLib has been installed with CPU eval support only. GPU support requires a CUDA development environment, not just runtime."
fi
