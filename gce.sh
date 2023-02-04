#! /bin/bash

sudo apt-get update
sudo apt-get install -y ubuntu-drivers-common python3-pip python-is-python3

sudo ubuntu-drivers autoinstall

# Reboot here
sudo reboot

pip install torch==1.12.0+cu113 torchvision==0.13.0+cu113 torchaudio==0.12.0 --extra-index-url https://download.pytorch.org/whl/cu113

sudo apt-get install -y vim git cmake autoconf libtool flex bison libbz2-dev libgl1-mesa-glx openjdk-8-jdk

git clone https://github.com/pufferai/pufferlib && cd pufferlib && pip3 install -e .[all] && cd ..
git clone https://github.com/pufferai/pufferai.github.io

# Using the CarperAI branches for active dev currently
# All changes will eventually be merged into the base Neural MMO repos
git clone https://github.com/CarperAI/nmmo-environment environment && cd environment && pip3 install -e .[cleanrl] && cd ..
git clone https://github.com/CarperAI/nmmo-baselines baselines


pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113

pip install nmmo[cleanrl]

# pip install pufferlib
