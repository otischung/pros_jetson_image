#!/bin/bash

export threads=4
export IMG_NAME="pros_jetson_image"
export ECR_URL="ghcr.io/otischung"
export TAG=$(date +%Y%m%d)
export DOCKER_CLI_EXPERIMENTAL=enabled

# Function to display a usage message
usage() {
    echo "Usage: $0 -t <tag>"
    exit 0
}

# Parse command-line options
while [ "$#" -gt 0 ]; do
    case "$1" in
        -t)
            TAG="$2"
            set=true
            shift 2
            ;;
        -h)
            usage
            shift
            exit 0
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            usage
            ;;
    esac
done


echo "Using tag: $TAG"
docker build --platform linux/amd64 \
    --tag $ECR_URL/$IMG_NAME:latest \
    --tag $ECR_URL/$IMG_NAME:$TAG \
    --build-arg THREADS=$threads \
    -f ./Dockerfile .
