FROM nvcr.io/nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04
ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /puffertank
WORKDIR /puffertank

# Core system packages
RUN apt update && apt install -y \
    build-essential curl git htop clang llvm tmux psmisc software-properties-common sudo \
    && apt-add-repository -y ppa:deadsnakes/ppa \ 
    && apt install -y python3.12 python3.12-dev  \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 12 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 12

# Install uv, torch, jax
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && . $HOME/.local/bin/env \
    && uv pip install --system --break-system-packages torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 \
    && uv pip install --system --break-system-packages jax[cuda12]

# Third party env deps
RUN apt install --no-install-recommends -y \
    # Nethack \
    autoconf libtool flex bison libbz2-dev 
RUN . $HOME/.local/bin/env \
    && uv pip install --system --break-system-packages \
    # Procgen mirror
    glfw==2.7
# Workaround for nethack/minihack
ENV READTHEDOCS=True

# CARBS hyperparam sweeps
RUN git clone https://github.com/pufferai/carbs \
    && . $HOME/.local/bin/env \
    && uv pip install --system --break-system-packages -e carbs

# PufferLib
ENV TORCH_CUDA_ARCH_LIST=Turing 
RUN git clone https://github.com/pufferai/pufferlib --branch dev \
    && . $HOME/.local/bin/env \
    && uv pip install --system --break-system-packages Cython \
    && uv pip install --system --break-system-packages --no-build-isolation -e pufferlib/[cleanrl] \
    && cd pufferlib \ 
    && python setup.py build_ext --inplace

# Neovim (btw)
RUN apt update \
    && apt install -y ninja-build gettext cmake unzip curl  \
    && git clone --single-branch --depth=1 https://github.com/neovim/neovim \
    && cd neovim \
    && make CMAKE_BUILD_TYPE=Release \
    && make install \
    && ln -s /usr/local/bin/nvim /usr/bin/nvim \
    && . $HOME/.local/bin/env \
    && uv pip install --system --break-system-packages pynvim \
    && sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# My personal config
COPY init.vim /root/.config/nvim/init.vim

# Run on container startup
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]

# Bashrc
RUN echo "export PS1=$' \xf0\x9f\[\x90\xa1\] '" >> ~/.bashrc \
 && echo "alias vim='/usr/bin/nvim'" >> ~/.bashrc \ 
 && echo "alias diff='diff --color --palette=':ad=36:de=31:ln=33''" >> ~/.bashrc \
 && echo "alias pip='uv pip'" >> ~/.bashrc \
 && echo "cd /puffertank/pufferlib" >> ~/.bashrc

RUN apt clean
CMD ["/bin/bash"]
