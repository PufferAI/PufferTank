FROM cnstark/pytorch:1.12.0-py3.9.12-cuda11.6.2-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /puffertank

RUN apt-get update
RUN apt-get install -y \
    # Basics
    vim git cmake \
    # NetHack
    autoconf libtool flex bison libbz2-dev \
    # Griddly
    libgl1-mesa-glx \
    # Gym MicroRTS
    openjdk-8-jdk \
    # Deepmind lab Bazel
    apt-transport-https curl gnupg \
    # Deepmind control rendering
    libglfw3 libglew2.0 \


# Avalon -- TODO: Figure out how to autoselect libnvidia-gl version
# To be added with gym 0.25 support
#RUN apt install -y --no-install-recommends libegl-dev libglew-dev libglfw3-dev libnvidia-gl-470 libopengl-dev libosmesa6 mesa-utils-extra

# Bazel dependencies
RUN apt-get -y update \
    && apt-get install --no-install-recommends -y \
    build-essential curl freeglut3 gettext git libffi-dev libglu1-mesa \
    libglu1-mesa-dev libjpeg-dev liblua5.1-0-dev libosmesa6-dev \
    libsdl2-dev lua5.1 pkg-config python-setuptools python3-dev \
    software-properties-common unzip zip zlib1g-dev g++

# Install Bazel
RUN apt-get install -y apt-transport-https curl gnupg  \
    && curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg  \
    && mv bazel.gpg /etc/apt/trusted.gpg.d/  \
    && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && apt-get update && apt-get install -y bazel

# Install Deepmind Lab
RUN git clone https://github.com/deepmind/lab.git  deepmind_lab \
    && cd deepmind_lab \
    && echo 'build --cxxopt=-std=c++17' > .bazelrc \
    && bazel build -c opt //python/pip_package:build_pip_package  \
    && ./bazel-bin/python/pip_package/build_pip_package /tmp/dmlab_pkg \
    && pip3 install --force-reinstall /tmp/dmlab_pkg/deepmind_lab-*.whl \
    && cd .. \

COPY vimrc ~/.vimrc

RUN git clone https://github.com/pufferai/pufferlib && cd pufferlib && pip3 install -e .[all] && cd ..
RUN git clone https://github.com/pufferai/pufferai.github.io docs
RUN git clone https://github.com/pufferai/pufferai.github.io dev-docs

# Using the CarperAI branches for active dev currently
# All changes will eventually be merged into the base Neural MMO repos
RUN git clone https://github.com/CarperAI/nmmo-environment environment && cd environment && pip3 install -e .[cleanrl] && cd ..
RUN git clone https://github.com/CarperAI/nmmo-baselines baselines