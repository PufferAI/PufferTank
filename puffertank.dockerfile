FROM nvcr.io/nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04
ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /puffertank
WORKDIR /puffertank

# Core system packages
# Custom installs without the cudnn base also need libnccl2 libnccl-dev
RUN apt-get update && apt-get install -y \
    curl wget sudo git build-essential clang htop gdb tmux psmisc \
    llvm libomp-dev libglfw3 libgl1-mesa-dev python3.12-dev

# Nsight Systems for profiling
RUN apt-get update && \
    apt-get install -y --no-install-recommends nsight-systems-2025.6.3

# PufferLib
RUN git clone https://github.com/pufferai/pufferlib --branch 4.0

# PyTorch
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && . $HOME/.local/bin/env \
    && uv venv --python 3.12 --prompt 🐡 venv \
    && . venv/bin/activate \
    && uv pip install torch --index-url https://download.pytorch.org/whl/cu130 \
    && uv pip install -e pufferlib

# Neovim (btw)
RUN . $HOME/.local/bin/env \
    && . venv/bin/activate \
    && apt-get install -y ninja-build gettext cmake unzip \
    && git clone --single-branch --depth=1 https://github.com/neovim/neovim \
    && cd neovim \
    && make CMAKE_BUILD_TYPE=Release \
    && make install \
    && ln -s /usr/local/bin/nvim /usr/bin/nvim \
    && . $HOME/.local/bin/env \
    && uv pip install pynvim \
    && sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# My personal config
COPY init.vim /root/.config/nvim/init.vim

# Run on container startup
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]

# Bashrc
RUN echo "export PS1=$''" >> ~/.bashrc \
 && echo "alias vim='/usr/bin/nvim'" >> ~/.bashrc \ 
 && echo "alias diff='diff --color --palette=':ad=36:de=31:ln=33''" >> ~/.bashrc \
 && echo "alias pip='uv pip'" >> ~/.bashrc \
 && echo ". /puffertank/venv/bin/activate" >> ~/.bashrc \
 && echo "cd /puffertank/pufferlib" >> ~/.bashrc

RUN apt-get clean
CMD ["/bin/bash"]
