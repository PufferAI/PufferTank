#! /bin/bash

sudo apt-get update
sudo apt-get install -y ubuntu-drivers-common python3-pip python-is-python3

sudo ubuntu-drivers autoinstall

# Reboot here

pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113

pip install nmmo[cleanrl]

# pip install pufferlib