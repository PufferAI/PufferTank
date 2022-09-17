#FROM ubuntu:20.04
FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime
WORKDIR /puffertank

RUN apt-get update
RUN apt-get install -y python3 python3-pip vim
#RUN apt-get install -y python-is-python3

COPY vimrc ~/.vimrc

#RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
RUN pip3 install nmmo

ENTRYPOINT ["tail", "-f", "/dev/null"]