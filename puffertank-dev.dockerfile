FROM pufferai/puffer-deps:latest

COPY vimrc /root/.vimrc
COPY version_check.py /root/version_check.py

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

RUN mkdir -p /puffertank
WORKDIR /puffertank

RUN git clone https://github.com/pufferai/pufferlib && pip3 install --user -e pufferlib/[cleanrl,atari]
RUN git clone --single-branch --depth=1 https://github.com/carperai/nmmo-environment && pip3 install --user -e nmmo-environment/[all]
RUN git clone --depth=1 https://github.com/carperai/nmmo-baselines

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]