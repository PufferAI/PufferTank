FROM pufferai/puffer-deps:latest

COPY version_check.py /root/version_check.py
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Copy my personal NeoVim config
COPY init.vim /root/.config/nvim/init.vim

# For the memes
RUN echo 'export PS1=" 🐡  "' >> ~/.bashrc \
 && echo "alias vim='/usr/bin/nvim'" >> ~/.bashrc

RUN mkdir -p /puffertank
WORKDIR /puffertank

RUN git clone https://github.com/facebookresearch/nle --recursive && pip3 install --no-dependencies -e nle/.

RUN git clone https://github.com/pufferai/pufferlib && pip3 install --user -e pufferlib/[cleanrl,atari]

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]
