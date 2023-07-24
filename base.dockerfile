FROM nvcr.io/nvidia/cuda:11.7.1-runtime-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    # Basics
    vim git cmake htop screen software-properties-common sudo \
    # Python
    && apt-add-repository -y ppa:deadsnakes/ppa \ 
    && apt-get install -y python3.9 \
    && apt-get install -y python3.9-dev \
    && apt-get install -y python3-pip \
    # Clean
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.9 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Pytorch 
ENV TORCH_VERSION=1.13.1
ENV TORCHVISION_VERSION=0.14.1
ENV TORCH_CUDA_VERSION=cu117

RUN pip3 install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/${TORCH_CUDA_VERSION} \
        torch==${TORCH_VERSION}+${TORCH_CUDA_VERSION} \
        torchvision==${TORCHVISION_VERSION}+${TORCH_CUDA_VERSION}