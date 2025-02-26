FROM pufferai/base:dev

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    # NetHack
    autoconf libtool flex bison libbz2-dev \
    # Griddly
    libgl1-mesa-glx \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* 

RUN pip3 install wheel

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
