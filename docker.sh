#!/bin/bash

# Default values
username="pufferai"  # replace with your Docker Hub username
image="puffertank"
tag="5.0"
name="5.0"

# Function for building Docker image
build() {
    if [ "$tag" = "4.0" ] || [ "$name" = "4.0" ]; then
        echo "Refusing to overwrite the live puffertank 4.0 image/container. Use tag/name 5.0."
        exit 1
    fi
    # Check if a Docker container with the same name already exists
    if [ "$(docker ps -aq -f name=^/${name}$)" ]; then
        # Stop and remove the existing container
        echo "A Docker container with the name ${name} already exists. Stopping and removing it..."
        docker stop ${name}
        docker rm ${name}
    fi
    echo "Building Docker image ${username}/${image}:${tag}..."
    docker buildx build --build-arg NVIDIA_VISIBLE_DEVICES=all --file puffertank.dockerfile -t ${username}/${image}:${tag} .
}

# Function for testing Docker image
# Need this on ubuntu for x11: xhost +local:docker
test() {
    # Need this on ubuntu for x11
    xhost +local:docker 2>/dev/null || true
    if [ "$(docker ps -aq -f name=^/${name}$)" ]; then
        echo "A Docker container with the name ${name} already exists. Starting it..."
        docker start ${name} >/dev/null
    else
        echo "Running Docker image ${username}/${image}:${tag}..."
        docker run -d \
            --name ${name} \
            --gpus all \
            --ipc host \
            --cgroupns=host \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v /mnt/wslg:/mnt/wslg \
            -v "$(pwd):/puffertank/docker" \
            -e DISPLAY=$DISPLAY \
            -e XAUTHORITY=/root/.Xauthority \
            -v $HOME/.Xauthority:/root/.Xauthority \
            --network host \
            -e WAYLAND_DISPLAY \
            -e NVIDIA_VISIBLE_DEVICES=all \
            -e NVIDIA_DRIVER_CAPABILITIES=all \
            -e XDG_RUNTIME_DIR \
            -e PULSE_SERVER \
            -e LANG=C.UTF-8 \
            -e LC_ALL=C.UTF-8 \
            -p 8000:8000 \
            ${username}/${image}:${tag} \
            sleep infinity >/dev/null
    fi
    echo "Attaching to ${name}. Exit the shell to detach (container stays up)."
    docker exec -it \
        -e LANG=C.UTF-8 \
        -e LC_ALL=C.UTF-8 \
        -e DISPLAY="${DISPLAY:-:0}" \
        -e WAYLAND_DISPLAY \
        -e XDG_RUNTIME_DIR \
        -e XAUTHORITY=/root/.Xauthority \
        -e __GLX_VENDOR_LIBRARY_NAME=mesa \
        ${name} bash
}

push() {
    echo "Pushing Docker image ${username}/${image}:${tag}..."
    docker push ${username}/${image}:${tag}
}

# Function for displaying usage instructions
usage() {
    echo "Usage: $0 command [-n name] [-i image] [-t tag] [-u username]"
    echo "Commands:"
    echo "  build"
    echo "  test"
    echo "  push"
}

# Main script
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

command=$1
shift

# Parse command-line arguments for name, tag, and username
while getopts n:i:t:u: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        i) image=${OPTARG};;
        t) tag=${OPTARG};;
        u) username=${OPTARG};;
    esac
done

case $command in
    build)
        build
        ;;
    test)
        test
        ;;
    push)
        push
        ;;
    *)
        usage
        ;;
esac
