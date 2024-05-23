#!/bin/bash

docker run -it --rm \
    --runtime nvidia \
    -v /run/jtop.sock:/run/jtop.sock \
    ghcr.io/otischung/pros_jetson_image:latest \
    /bin/bash
