#!/bin/bash

# Default values
username="pufferai"  # replace with your Docker Hub username
dockerfile=""  # Dockerfile to use
name="puffertank"
image="puffertank"
tag="latest"

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
    docker build -t ${username}/${image}:${tag} -f ${dockerfile} .
}

# Function for testing Docker image
test() {
    # Check if a Docker container with the same name already exists
    if [ "$(docker ps -aq -f name=^/${name}$)" ]; then
        # If the container exists and is stopped, start it
        echo "A Docker container with the name ${name} already exists. Starting it..."
        docker start ${name}
    else
        # If the container does not exist, run a new one
        echo "Running Docker image ${username}/${image}:${tag} and executing shell..."
        docker run -it \
            --name ${name} \
            --gpus all \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v /mnt/wslg:/mnt/wslg \
            -v "$(pwd):/puffertank/docker" \
            -e DISPLAY \
            -e WAYLAND_DISPLAY \
            -e XDG_RUNTIME_DIR \
            -e PULSE_SERVER \
            ${username}/${image}:${tag} bash
    fi
    # Attach to the running container
    docker exec -it ${name} bash
}

# Function for pushing Docker image
push() {
    echo "Pushing Docker image ${username}/${name}:${tag}..."
    docker push ${username}/${name}:${tag}
}

# Function for displaying usage instructions
usage() {
    echo "Usage: $0 command [-d dockerfile] [-n name] [-i image] [-t tag] [-u username]"
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
