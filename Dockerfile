FROM gcr.io/deeplearning-platform-release/pytorch-gpu.1-12:latest
WORKDIR /puffertank

RUN apt-get update
RUN apt-get install -y vim cmake autoconf libtool flex bison libbz2-dev

COPY vimrc ~/.vimrc

RUN git clone https://github.com/pufferai/pufferlib && pip3 install -e pufferlib
RUN git clone https://github.com/neuralmmo/environment && cd environment && git checkout --track origin/puffer && pip3 install -e . && cd ..
RUN git clone https://github.com/neuralmmo/baselines && cd baselines && git checkout --track origin/puffer && cd ..