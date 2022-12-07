FROM cnstark/pytorch:1.12.0-py3.9.12-cuda11.6.2-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /puffertank

RUN apt-get update
RUN apt-get install -y vim git cmake autoconf libtool flex bison libbz2-dev

COPY vimrc ~/.vimrc

RUN git clone https://github.com/pufferai/pufferlib && cd pufferlib && pip3 install -e . && cd ..
RUN git clone https://github.com/CarperAI/nmmo-environment environment && cd environment && pip3 install -e .[cleanrl] && cd ..
RUN git clone https://github.com/CarperAI/nmmo-baselines baselines