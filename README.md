# Puffertank

# Getting Started

### 1. Install Docker

Docker is a containerization technology to package code and its dependencies. Install and configure docker, by following the official install instructions for your operationg system and then completing the post-installation steps.

[Docker Engine](https://docs.docker.com/engine/)
[Docker Compose](https://docs.docker.com/compose/)
[Docker BuildX](https://docs.docker.com/engine/reference/commandline/buildx/)

or alternatively, bundled [Docker Desktop](https://docs.docker.com/desktop/).

*Puffertank requires GPU*

(Linux) [Nvidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#installation-guide) may also need to be installed.

Test your docker installation with `docker run hello-world`.

### 2. Download Puffertank image

Clone this repository, or alternatively can be found on the docker registry as [puffertank-compeititon-dev](https://hub.docker.com/r/pufferai/puffertank-competition-dev).

### 3. (Optional) Containerized development in VS code

[Containerized Development](https://code.visualstudio.com/docs/devcontainers/containers)

#### 1. Install VSCode
[Visual Studio Code](https://code.visualstudio.com/)

#### 2. Install DevContainers Extension

Extensions > Dev Containers > Install

#### 3. Dev Containers: Reopen in container

Open Puffertank folder in new window > Bottom left corner > Reopen in container

The source code can be found contained within the container,  File > Open Folder.
