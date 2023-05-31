FROM nvcr.io/nvidia/cuda:11.7.1-runtime-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    # Basics
    vim git cmake htop screen software-properties-common sudo \
    # Python
    && apt-add-repository ppa:deadsnakes/ppa \ 
    && apt-get install -y python3.9 \
    && apt-get install -y python3-pip \
    # Clean
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Pytorch 
ENV TORCH_VERSION=1.13.1
ENV TORCHVISION_VERSION=0.14.1
ENV TORCH_CUDA_VERSION=cu117

RUN pip3 install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/${TORCH_CUDA_VERSION} \
        torch==${TORCH_VERSION}+${TORCH_CUDA_VERSION} \
        torchvision==${TORCHVISION_VERSION}+${TORCH_CUDA_VERSION}

COPY vimrc /root/.vimrc

RUN echo 'export PYTHONPATH=.:${PYTHONPATH}' >> /root/.bashrc

RUN git clone https://github.com/pufferai/pufferlib && pip3 install --user -e pufferlib/[cleanrl,atari]

# Full install of Neural MMO with local docs
RUN git clone --single-branch --depth=1 https://github.com/carperai/nmmo-environment && pip3 install --user -e nmmo-environment/[all]
RUN git clone --depth=1 https://github.com/carperai/nmmo-baselines

RUN mkdir /puffertank
COPY . /puffertank
WORKDIR /puffertank