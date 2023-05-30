FROM nvcr.io/nvidia/cuda:11.7.1-runtime-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /puffertank

RUN apt-get update
RUN apt-get install -y \
    # Basics
    vim git cmake htop screen software-properties-common \
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

RUN git clone https://github.com/pufferai/pufferlib --single-branch --depth=1 && \
    pip3 install -e pufferlib/[atari,cleanrl]
RUN git clone https://github.com/neuralmmo/environment --single-branch --depth=1 environment && \
    pip3 install -e environment
RUN git clone https://github.com/neuralmmo/baselines --single-branch --depth=1 baselines && \
    pip3 install -r baselines/requirements.txt
