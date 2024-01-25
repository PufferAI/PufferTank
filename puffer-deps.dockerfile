FROM pufferai/base:latest

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    # Avalon
    # libegl-dev libglew-dev libglfw3-dev \
    # libopengl-dev libosmesa6 mesa-utils-extra \
    # NetHack
    autoconf libtool flex bison libbz2-dev \
    # Griddly
    libgl1-mesa-glx \
    # Gym MicroRTS
    openjdk-8-jdk \
    # Deepmind lab Bazel
    apt-transport-https curl gnupg \
    # Deepmind control rendering
    # Note - no libglew2.0?
    libglfw3 libglew-dev \
    # Bazel dependencies
    build-essential freeglut3 gettext git libffi-dev libglu1-mesa \
    libglu1-mesa-dev libjpeg-dev liblua5.1-0-dev libosmesa6-dev \
    libsdl2-dev lua5.1 pkg-config python-setuptools python3-dev \
    software-properties-common unzip zip zlib1g-dev g++ \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* 

RUN pip3 install wheel

# Install Bazel
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg  \
    && mv bazel.gpg /etc/apt/trusted.gpg.d/  \
    && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && apt-get update && apt-get install --no-install-recommends -y bazel \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Install Deepmind Lab
RUN rm -rf deepmind_lab \
    && git clone https://github.com/deepmind/lab.git deepmind_lab \
    && cd deepmind_lab \
    && echo 'build --cxxopt=-std=c++17' > .bazelrc \
    && bazel build -c opt //python/pip_package:build_pip_package  \
    && ./bazel-bin/python/pip_package/build_pip_package /tmp/dmlab_pkg \
    && pip3 install --force-reinstall /tmp/dmlab_pkg/deepmind_lab-*.whl \
    && rm -rf /tmp/dmlab_pkg/deepmind_lab-*.whl \
    && rm -rf .git \
    && cd .. \
    && rm -rf ~/.cache/bazel/ \
    && rm -rf deepmind_lab

# Install Neovim and VimPlug
RUN apt update \
    && apt install -y ninja-build gettext cmake unzip curl  \
    && git clone --single-branch --depth=1 https://github.com/neovim/neovim \
    && cd neovim \
    && make CMAKE_BUILD_TYPE=Release \
    && make install \
    && ln -s /usr/local/bin/nvim /usr/bin/nvim \
    && pip3 install pynvim \
    && sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    
# Install Node using NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash \
    && . "$HOME/.nvm/nvm.sh" \
    && nvm install v20.3.1 \
    && nvm use v20.3.1

# Avalon -- TODO: Figure out how to autoselect libnvidia-gl version
