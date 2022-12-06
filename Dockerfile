FROM gcr.io/deeplearning-platform-release/pytorch-gpu.1-12:latest
WORKDIR /puffertank

RUN apt-get update
RUN apt-get install -y vim git cmake autoconf libtool flex bison libbz2-dev

COPY vimrc ~/.vimrc

RUN git clone https://github.com/pufferai/pufferlib && pip3 install -e pufferlib
RUN git clone https://github.com/CarperAI/nmmo-environment environment && cd environment && pip3 install -e .[cleanrl] && cd ..
RUN git clone https://github.com/CarperAI/nmmo-baselines baselines