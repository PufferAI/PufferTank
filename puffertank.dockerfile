# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Stage 0: build Neovim from source (latest master). The final image only
# copies the installed runtime (/opt/nvim) -- not cmake/ninja/gettext, the
# source tree, or the build artifacts.
# ---------------------------------------------------------------------------
FROM nvcr.io/nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04 AS nvim-builder
ARG DEBIAN_FRONTEND=noninteractive
ARG NEOVIM_REF=master

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates build-essential ninja-build gettext cmake unzip

RUN git clone --single-branch --depth=1 --branch ${NEOVIM_REF} https://github.com/neovim/neovim \
    && cd neovim \
    && make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/opt/nvim -j$(nproc) \
    && make install

# ---------------------------------------------------------------------------
# Stage 1: the dev container. Layers are ordered from least-frequently to
# most-frequently changed, so expensive work (apt, nvim, torch, pufferlib)
# stays cached while config files churn. Cache mounts survive rebuilds.
# ---------------------------------------------------------------------------
FROM nvcr.io/nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /puffertank

# Core system packages.
# Custom installs without the cudnn base also need libnccl2 libnccl-dev.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y curl wget sudo git build-essential clang unzip \
        htop gdb tmux psmisc llvm ccache \
        sqlite3 \
        libomp-dev libglfw3 libgl1-mesa-dev python3.12-dev

# Nsight Systems for profiling (own layer: large, and version-bumped on its own).
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends nsight-systems-2025.6.3

# UV venv + pynvim
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && . $HOME/.local/bin/env \
    && uv venv --python 3.12 --prompt 🐡 venv \
    && . venv/bin/activate \
    && uv pip install pynvim

# Neovim runtime, built in the stage above
COPY --from=nvim-builder /opt/nvim /opt/nvim
RUN ln -s /opt/nvim/bin/nvim /usr/bin/nvim \
    && sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# PyTorch. The uv cache mount persists across builds: ~3GB of wheels download once.
RUN --mount=type=cache,target=/root/.cache/uv \
    . $HOME/.local/bin/env \
    && . venv/bin/activate \
    && uv pip install torch --index-url https://download.pytorch.org/whl/cu130

# PufferLib + docs + 20k baseline experiments viewable with Constellation.
# Bump PUFFERLIB_REF / PUFFERAI_REF (or pass --build-arg) to refresh this layer.
ARG PUFFERLIB_REF=4.0
ARG PUFFERAI_REF=4.0
RUN --mount=type=cache,target=/root/.ccache \
    --mount=type=cache,target=/root/.cache/uv \
    --mount=type=cache,target=/root/.cache/puffer \
    . $HOME/.local/bin/env \
    && git clone https://github.com/pufferai/pufferlib --branch ${PUFFERLIB_REF} \
    && git clone https://github.com/pufferai/puffer.ai --branch ${PUFFERAI_REF} \
    && . venv/bin/activate \
    && cd pufferlib \
    && uv pip install -e . \
    && bash build.sh breakout \
    && curl -L -o /root/.cache/puffer/experiments.zip https://github.com/PufferAI/PufferLib/releases/download/experiments/experiments.zip \
    && unzip -q /root/.cache/puffer/experiments.zip \
    && python constellation/cache_data.py --full \
    && bash build.sh constellation --fast

# Bashrc
RUN echo "export PS1=$''" >> ~/.bashrc \
    && echo "alias vim='/usr/bin/nvim'" >> ~/.bashrc \
    && echo "alias diff='diff --color --palette=':ad=36:de=31:ln=33''" >> ~/.bashrc \
    && echo "alias pip='uv pip'" >> ~/.bashrc \
    && echo ". /puffertank/venv/bin/activate" >> ~/.bashrc \
    && echo "cd /puffertank/pufferlib" >> ~/.bashrc \
    && echo "export __GLX_VENDOR_LIBRARY_NAME=mesa" >> ~/.bashrc

# Config files last: the only COPY steps, so nothing above them is invalidated.
COPY --chmod=755 entrypoint.sh /root/entrypoint.sh
COPY init.vim /root/.config/nvim/init.vim

# Run on container startup
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]
