FROM cnstark/pytorch:1.12.0-py3.9.12-cuda11.6.2-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /puffertank

RUN apt-get update
RUN apt-get install -y \
    # Basics
    vim git cmake htop screen && \
    # Clean
    apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY vimrc /root/.vimrc

RUN pip3 install wheel

RUN echo 'export PYTHONPATH=.:${PYTHONPATH}' >> /root/.bashrc

RUN git clone https://github.com/pufferai/pufferlib && \
    pip3 install -e pufferlib/[atari,cleanrl]

RUN git clone https://github.com/neuralmmo/environment --single-branch --depth=1 environment && \
    pip3 install -e neuralmmo/environment/[all]
RUN git clone https://github.com/neuralmmo/baselines --single-branch --depth=1 baselines
