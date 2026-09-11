FROM nvcr.io/nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04
ARG DEBIAN_FRONTEND=noninteractive
# POSIX/C locale makes wcwidth(🐡)=-1, so readline wraps the prompt onto itself.
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV __GLX_VENDOR_LIBRARY_NAME=mesa

WORKDIR /puffertank

# Container utilities. PufferLib/raylib/nethack packages come from install.sh.
RUN apt-get update && apt-get install -y \
        curl wget sudo htop gdb tmux psmisc llvm \
    && apt-get install -y --no-install-recommends nsight-systems-2025.6.3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Neovim (btw) — official tarball, no Python provider
RUN curl -fsSL -o /tmp/nvim.tar.gz \
        https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz \
    && tar xzf /tmp/nvim.tar.gz -C /opt \
    && ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim \
    && rm /tmp/nvim.tar.gz \
    && curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
COPY init.vim /root/.config/nvim/init.vim

COPY install.sh /puffertank/install.sh
RUN bash /puffertank/install.sh \
    && (nvim --headless +PlugInstall +qall || true) \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]

RUN cat >> ~/.bashrc << 'EOF'
export LANG=C.UTF-8 LC_ALL=C.UTF-8
export PS1='🐡 \[\e[38;5;51m\]>\[\e[0m\] '
alias vim='/usr/bin/nvim'
alias diff='diff --color --palette=':ad=36:de=31:ln=33''
cd /puffertank/pufferlib
export __GLX_VENDOR_LIBRARY_NAME=mesa
EOF

CMD ["/bin/bash"]
