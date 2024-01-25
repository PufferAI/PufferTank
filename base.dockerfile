FROM nvcr.io/nvidia/cuda:12.1.0-runtime-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    # Basics
    vim git curl cmake htop screen software-properties-common sudo \
    # Python
    && apt-add-repository -y ppa:deadsnakes/ppa \ 
    && apt-get install -y python3.11 \
    && apt-get install -y python3.11-dev \
    && apt-get install -y python3.11-distutils \
    # Clean
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Install Pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# PyTorch
RUN python3.11 -m pip install --upgrade pip
RUN pip3 install --no-cache-dir torch==2.1.0 torchvision
