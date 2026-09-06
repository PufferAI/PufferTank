#!/bin/bash

# Default values
username="pufferai"  # replace with your Docker Hub username
dockerfile=""  # Dockerfile to use
image="puffertank"
tag="4.0"
name="4.0"

# Function for building Docker image
build() {
    # Verify a Dockerfile was provided
    if [ -z "$dockerfile" ]; then
        echo "You must specify a Dockerfile with -d."
        exit 1
    fi
    # Check if a Docker container with the same name already exists
    if [ "$(docker ps -aq -f name=^/${name}$)" ]; then
        # Stop and remove the existing container
        echo "A Docker container with the name ${name} already exists. Stopping and removing it..."
        docker stop ${name}
        docker rm ${name}
    fi
    echo "Building Docker image ${username}/${image}:${tag} with Dockerfile ${dockerfile}..."
    #docker build ${username}/${image}:${tag} -f ${dockerfile} .
    docker buildx build --build-arg NVIDIA_VISIBLE_DEVICES=all --file ${dockerfile} -t ${username}/${image}:${tag} .
}

# Function for testing Docker image
# Remote raylib: Xvfb + browser stream on :6080 (see x11_ssh.sh).
# Local seated desktop still uses the native X window.
test() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=x11_ssh.sh
    . "${SCRIPT_DIR}/x11_ssh.sh"
    prepare_x11 || true
    mapfile -t x11_flags < <(x11_docker_flags)

    # Check if a Docker container with the same name already exists
    if [ "$(docker ps -aq -f name=${name})" ]; then
        # If the container exists and is stopped, start it
        echo "A Docker container with the name ${name} already exists. Starting it..."
        docker start ${name}
    else
        # If the container does not exist, run a new one
        echo "Running Docker image ${username}/${image}:${tag} and executing shell..."
        docker run -it \
            --name ${name} \
            --gpus all \
	    --ipc host \
	    --cgroupns=host \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v /mnt/wslg:/mnt/wslg \
            -v "$(pwd):/puffertank/docker" \
            --network host \
            -e WAYLAND_DISPLAY \
            -e NVIDIA_VISIBLE_DEVICES=all \
            -e NVIDIA_DRIVER_CAPABILITIES=all \
            -e XDG_RUNTIME_DIR \
            -e PULSE_SERVER \
            -p 8000:8000 \
            "${x11_flags[@]}" \
            ${username}/${image}:${tag} bash
    fi
    # Attach with *this* SSH session's DISPLAY (not the one baked at docker run)
    docker exec -it "${x11_flags[@]}" ${name} bash
}

push() {
    echo "Pushing Docker image ${username}/${name}:${tag}..."
    docker push ${username}/${name}:${tag}
}

# Function for displaying usage instructions
usage() {
    echo "Usage: $0 command [-d dockerfile] [-n name] [-i image] [-t tag] [-u username]"
    echo "Commands:"
    echo "  build"
    echo "  test    # enter the container; remote raylib streams to :6080"
    echo "  push"
    echo "Remote raylib: ssh user@host && ./docker.sh test && ./breakout"
    echo "  then open the printed http://<host>:6080/  (ssh -X is not used)"
}

# Main script
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

command=$1
shift

# Parse command-line arguments for Dockerfile, name, tag, and username
while getopts n:i:t:u:d: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        i) image=${OPTARG};;
        t) tag=${OPTARG};;
        u) username=${OPTARG};;
        d) dockerfile=${OPTARG};;
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
