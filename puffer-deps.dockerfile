FROM pufferai/base:latest

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    # NetHack
    autoconf libtool flex bison libbz2-dev \
    # Griddly
    libgl1-mesa-glx \
    # Gym MicroRTS
    openjdk-8-jdk \
    # Deepmind lab Bazel
    apt-transport-https curl gnupg \
    # Deepmind control rendering
    # Note - no libglew2.0?
    libglfw3 libglew-dev \
    # Bazel dependencies
    build-essential freeglut3 gettext git libffi-dev libglu1-mesa \
    libglu1-mesa-dev libjpeg-dev liblua5.1-0-dev libosmesa6-dev \
    libsdl2-dev lua5.1 pkg-config python-setuptools python3-dev \
    software-properties-common unzip zip zlib1g-dev g++ \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* 

# Avalon -- TODO: Figure out how to autoselect libnvidia-gl version
# To be added with gym 0.25 support
# RUN apt install --no-install-recommends -y libegl-dev libglew-dev libglfw3-dev libnvidia-gl-470 libopengl-dev libosmesa6 mesa-utils-extra

RUN pip3 install wheel

# Install Bazel
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg  \
    && mv bazel.gpg /etc/apt/trusted.gpg.d/  \
    && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && apt-get update && apt-get install --no-install-recommends -y bazel \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Install Deepmind Lab
RUN rm -rf deepmind_lab \
    && git clone https://github.com/deepmind/lab.git deepmind_lab \
    && cd deepmind_lab \
    && echo 'build --cxxopt=-std=c++17' > .bazelrc \
    && bazel build -c opt //python/pip_package:build_pip_package  \
    && ./bazel-bin/python/pip_package/build_pip_package /tmp/dmlab_pkg \
    && pip3 install --force-reinstall /tmp/dmlab_pkg/deepmind_lab-*.whl \
    && rm -rf /tmp/dmlab_pkg/deepmind_lab-*.whl \
    && rm -rf .git \
    && cd .. \
    && rm -rf ~/.cache/bazel/ \
    && rm -rf deepmind_lab