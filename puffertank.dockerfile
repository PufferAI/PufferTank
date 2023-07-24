FROM pufferai/puffer-deps:latest

COPY vimrc /root/.vimrc
COPY version_check.py /root/version_check.py

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

RUN mkdir /puffertank
WORKDIR /puffertank

RUN pip3 install --user pufferlib[cleanrl,atari]

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]