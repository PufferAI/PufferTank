FROM pufferai/puffer-deps:dev

RUN mkdir -p /puffertank
WORKDIR /puffertank

# Workaround for nethack/minihack
ENV READTHEDOCS=True

# CARBS hyperparam sweeps
RUN git clone https://github.com/pufferai/carbs && pip3 install --user -e carbs/

ADD https://api.github.com/repos/pufferai/pufferlib/git/refs/heads/dev version.json
RUN git clone https://github.com/pufferai/pufferlib --branch dev && SETUPTOOLS_ENABLE_FEATURES="legacy-editable" pip3 install --user -e pufferlib/[cleanrl]

# Procgen fix
RUN pip install glfw==2.7

COPY version_check.py /root/version_check.py
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Copy my personal NeoVim config
COPY init.vim /root/.config/nvim/init.vim

# For the memes. Properly escaped pufferfish prompt
RUN echo "export PS1=$' \xf0\x9f\[\x90\xa1\] '" >> ~/.bashrc \
 && echo "alias vim='/usr/bin/nvim'" >> ~/.bashrc \ 
 && echo "alias diff='diff --color --palette=':ad=36:de=31:ln=33''" >> ~/.bashrc

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]
