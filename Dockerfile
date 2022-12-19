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
    openjdk-8-jdk

# Avalon -- TODO: Figure out how to autoselect libnvidia-gl version
# To be added with gym 0.25 support
#RUN apt install -y --no-install-recommends libegl-dev libglew-dev libglfw3-dev libnvidia-gl-470 libopengl-dev libosmesa6 mesa-utils-extra

COPY vimrc ~/.vimrc

RUN git clone https://github.com/pufferai/pufferlib && cd pufferlib && pip3 install -e . && cd ..

# Using the CarperAI branches for active dev currently
# All changes will eventually be merged into the base Neural MMO repos
RUN git clone https://github.com/CarperAI/nmmo-environment environment && cd environment && pip3 install -e .[cleanrl] && cd ..
RUN git clone https://github.com/CarperAI/nmmo-baselines baselines