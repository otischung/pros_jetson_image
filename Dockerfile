# FROM nvcr.io/nvidia/l4t-base:r36.2.0
FROM dustynv/ros:humble-ros-base-l4t-r36.2.0
ENV ROS2_WS /workspaces
ENV ROS_DOMAIN_ID=1
ENV ROS_DISTRO humble
ARG TORCH_INSTALL="https://developer.download.nvidia.com/compute/redist/jp/v60dp/pytorch/torch-2.3.0a0+6ddf5cf85e.nv24.04.14026654-cp310-cp310-linux_aarch64.whl"
ARG THREADS=4

SHELL ["/bin/bash", "-c"] 

##### Copy Source Code #####
COPY . /tmp

##### Environment Settings #####
WORKDIR /tmp

# Copy the run command for rebuilding colcon. You can source it.
RUN mkdir ${ROS2_WS} && \
    mv /tmp/rebuild_colcon.rc ${ROS2_WS} && \

# Remove the run command in ros2-humble image
    rm /root/.bashrc && \

# Entrypoint
    mv /tmp/ros_entrypoint.bash /ros_entrypoint.bash && \
    chmod +x /ros_entrypoint.bash && \

# System Upgrade
    apt update && \
    apt upgrade -y && \

# PyTorch and Others Installation
    apt install -y \
        axel \
        bash-completion \
        bat \
        bmon \
        build-essential \
        curl \
        git \
        git-flow \
        htop \
        i2c-tools \
        iotop \
        iproute2 \
        libncurses5-dev \
        libncursesw5-dev \
        lsof \
        ncdu \
        net-tools \
        nvtop \
        python3-pip \
        python3-venv \
        screen \
        tig \
        tmux \
        tree \
        vim \
        wget \
        zsh && \

    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \

# install boost serial and json
    apt install -y \
        libboost-all-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libserial-dev \
        nlohmann-json3-dev && \

# Soft Link
    ln -s /usr/bin/batcat /usr/bin/bat && \

# Install oh-my-bash
    curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh && \

# Use our pre-defined bashrc
    mv /tmp/.bashrc /root && \
    ln -s /root/.bashrc /.bashrc && \

##### Pytorch Installation #####
    apt install -y libopenblas-dev && \
    pip install --no-cache-dir $TORCH_INSTALL && \

##### mediapipe Installation #####
    pip install --no-cache-dir mediapipe && \

# ##### colcon Installation #####
# WORKDIR ${ROS2_WS}
# ### Copy Source Code
# # Rplidar
# RUN mv /tmp/rplidar_src ./src && \

# # Astra Camera
#     mv /tmp/camera_src ./src && \

# ### Installation ###
# # Rplidar
#     rosdep update && \

# # Build your ROS packages
#     rosdep install -q -y -r --from-paths src --ignore-src && \
#     # apt install ros-${ROS_DISTRO}-navigation2 ros-${ROS_DISTRO}-nav2-bringup -y && \
#     # . /opt/ros/humble/setup.sh && \
#     colcon build --packages-select rplidar_ros --symlink-install --parallel-workers ${THREADS} && \
#     colcon build --packages-select csm --symlink-install --parallel-workers ${THREADS} && \
#     colcon build --packages-select ros2_laser_scan_matcher --symlink-install --parallel-workers ${THREADS} && \
#     . /opt/ros/humble/setup.sh && \
#     colcon build --packages-select slam_toolbox --symlink-install --parallel-workers ${THREADS} && \

#     # apt install ros-humble-rplidar-ros && \

# ##### Astra Camera Installation #####
# # install dependencies
#     # apt install -y libgflags-dev ros-${ROS_DISTRO}-image-geometry ros-${ROS_DISTRO}-camera-info-manager \
#     #                ros-${ROS_DISTRO}-image-transport ros-${ROS_DISTRO}-image-publisher && \
#     # apt install -y libgoogle-glog-dev libusb-1.0-0-dev libeigen3-dev libopenni2-dev nlohmann-json3-dev && \
#     # apt install -y ros-${ROS_DISTRO}-image-transport-plugins && \
#     git clone https://github.com/libuvc/libuvc.git /temp/libuvc && \
#     mkdir -p /temp/libuvc/build
# WORKDIR /temp/libuvc/build
# RUN cmake .. && \
#     make -j${THREADS} && \
#     make install && \
#     ldconfig

# # Build
# WORKDIR ${ROS2_WS}
# RUN rosdep install -q -y -r --from-paths src --ignore-src && \
#     . /opt/ros/humble/setup.sh && colcon build --packages-select pros_image --symlink-install --parallel-workers ${THREADS} && \
#     . /opt/ros/humble/setup.sh && colcon build --packages-select astra_camera_msgs --symlink-install --parallel-workers ${THREADS} && \
#     . /opt/ros/humble/setup.sh && colcon build --packages-select astra_camera --symlink-install --parallel-workers ${THREADS} && \

# ##### Sipeed A075v #####
#     # https://wiki.sipeed.com/hardware/zh/maixsense/maixsense-a075v/maixsense-a075v.html?fbclid=IwZXh0bgNhZW0CMTAAAR0no57ZkSZQn1Vp0KB96VTxY7GkhBXH63Mz5LLvd-2o8IOXLnhKPf5IP9Y_aem_AUoqMDGoSwdGA0OwfJt78WNY0xl7XZ5pmuWfUfXxnfEzrEP-D-6yCmQ2ZnQ0-hieiYEBVvUv7tMQ978iflqkcb70
#     mv /tmp/sipeed_camera_src/ros2 ${ROS2_WS}/src && \
#     colcon build --packages-select ros2 --symlink-install --parallel-workers ${THREADS} && \

# ##### YDLidar #####
# # SDK compile installation
#     mkdir -p /tmp/ydlidar_src/YDLidar-SDK/build
# WORKDIR /tmp/ydlidar_src/YDLidar-SDK/build
# RUN cmake .. && \
#     make -j && \
#     make -j install && \

# # colcon build
#     # This is used to fix the YDLidar fatal error: [YDLIDAR] Failed to start scan mode: ffffffff
#     rm /tmp/ydlidar_src/ydlidar_ros2_ws/src/ydlidar_ros2_driver/params/ydlidar.yaml && \
#     mv /tmp/ydlidar_src/ydlidar.yaml /tmp/ydlidar_src/ydlidar_ros2_ws/src/ydlidar_ros2_driver/params/ydlidar.yaml && \
#     mv /tmp/ydlidar_src/ydlidar_ros2_ws/src/ydlidar_ros2_driver ${ROS2_WS}/src

# WORKDIR ${ROS2_WS}
# RUN source /opt/ros/humble/setup.bash && \
#     colcon build --packages-select ydlidar_ros2_driver --symlink-install --parallel-workers ${THREADS} && \

##### Post-Settings #####
# Clear tmp and cache
    rm -rf /tmp/* && \
    rm -rf /temp/* && \
    rm -rf /var/lib/apt/lists/*

# # Add nvcc to PATH
# ENV PATH="$PATH:/usr/local/cuda/bin"

WORKDIR ${ROS2_WS}
ENTRYPOINT [ "/ros_entrypoint.bash" ]
CMD ["bash", "-l"]
