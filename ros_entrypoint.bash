#!/bin/bash

set -e
# setup ros2 environment
source /root/.bashrc
source "$ROS2_WS/install/setup.bash" || true
exec "$@"
