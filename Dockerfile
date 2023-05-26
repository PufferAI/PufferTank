FROM cnstark/pytorch:1.12.0-py3.9.12-cuda11.6.2-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
    sudo git cmake vim htop screen \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY vimrc /root/.vimrc

RUN echo 'export PYTHONPATH=.:${PYTHONPATH}' >> /root/.bashrc

RUN git clone https://github.com/pufferai/pufferlib && pip3 install --user -e pufferlib/[cleanrl,atari]

# Full install of Neural MMO with local docs
RUN git clone --single-branch --depth=1 https://github.com/carperai/nmmo-environment && pip3 install --user -e nmmo-environment/[all]
RUN git clone --depth=1 https://github.com/carperai/nmmo-baselines

RUN mkdir /puffertank
COPY . /puffertank
WORKDIR /puffertank