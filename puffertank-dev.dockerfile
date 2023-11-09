FROM pufferai/puffer-deps:latest

COPY version_check.py /root/version_check.py

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

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
    && nvm install 20 \
    && nvm use 20

# Copy my personal config
COPY init.vim /root/.config/nvim/init.vim

# For the memes
RUN echo 'export PS1=" 🐡  "' >> ~/.bashrc \
 && echo "alias vim='/usr/bin/nvim'" >> ~/.bashrc

RUN mkdir -p /puffertank
WORKDIR /puffertank

RUN git clone https://github.com/pufferai/pufferlib && pip3 install --user -e pufferlib/[cleanrl,atari]
RUN git clone --single-branch --depth=1 https://github.com/carperai/nmmo-environment && pip3 install --user -e nmmo-environment/[all]
RUN git clone --depth=1 https://github.com/carperai/nmmo-baselines

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]
