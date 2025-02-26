FROM nvcr.io/nvidia/cuda:12.4.0-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    # Basics
    vim git curl htop clang llvm tmux psmisc software-properties-common sudo \
    # Python
    && apt-add-repository -y ppa:deadsnakes/ppa \ 
    && apt-get install -y python3.12 \
    && apt-get install -y python3.12-dev \
    # Clean
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Install Pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 12 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 12

# PyTorch
RUN python3.12 -m pip install --upgrade pip
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

#JAX
RUN pip3 install jax[cuda12]
