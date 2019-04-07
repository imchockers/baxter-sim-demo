# https://hub.docker.com/r/davetcoleman/baxter_simulator/~/dockerfile/
# vicariousinc/baxter-simulator:kinetic
# Run simulated Baxter in Gazebo

FROM osrf/ros:kinetic-desktop-full
MAINTAINER Dave Coleman dave@dav.ee

ENV TERM xterm

# Setup catkin workspace
ENV CATKIN_WS=/root/ws_baxter
RUN mkdir -p $CATKIN_WS/src
WORKDIR $CATKIN_WS/src

# Download source code
RUN wstool init . && \
    wstool merge https://raw.githubusercontent.com/vicariousinc/baxter_simulator/${ROS_DISTRO}-gazebo7/baxter_simulator.rosinstall && \
    wstool update
# Add time_jump package
#RUN catkin_create_pkg time_jump rospy tf2_msgs jsk_recognition_msgs message_filters
#RUN mkdir ./time_jump/scripts
#WORKDIR $CATKIN_WS/src/time_jump/scripts
#RUN git clone https://github.com/cosc2408-mixed-reality/ros-tf-time-jump.git
#WORKDIR $CATKIN_WS/src

RUN git clone https://github.com/imchockers/ros-tf-time-jump.git
RUN git clone https://github.com/imchockers/kinect_based_arm_tracking.git

# Update apt-get because previous images clear this cache
# Commands are combined in single RUN statement with "apt/lists" folder removal to reduce image size
RUN apt-get -qq update && \
    # Install some base dependencies
    apt-get -qq install -y \
        # Some source builds require a package.xml be downloaded via wget from an external location
        wget \
        # Required for rosdep command
        sudo \
        # Required for installing dependencies
        python-rosdep \
        # Preferred build tool
        python-catkin-tools && \
    # Download all dependencies
    rosdep update && \
    rosdep install -y --from-paths . --ignore-src --rosdistro ${ROS_DISTRO} --as-root=apt:false && \
    # Clear apt-cache to reduce image size
    rm -rf /var/lib/apt/lists/*

# Replacing shell with bash for later docker build commands
RUN mv /bin/sh /bin/sh-old && \
    ln -s /bin/bash /bin/sh

# Build repo
WORKDIR $CATKIN_WS
ENV PYTHONIOENCODING UTF-8
RUN catkin config --extend /opt/ros/${ROS_DISTRO} --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    # Status rate is limited so that just enough info is shown to keep Docker from timing out, but not too much
    # such that the Docker log gets too long (another form of timeout)
    # changed --jobs flag to 4 to speed up the build process
    catkin build --jobs 4 --limit-status-rate 0.001 --no-notify

#
# VXLab extensions...
#

COPY sources.list.mirrors /etc/apt/sources.list

RUN apt-get update && apt-get -y install vim-tiny

ADD baxter.sh baxter.sh
RUN chmod +x baxter.sh
#ADD vncpasswd vncpasswd

#RUN groupadd -r vxlab && adduser --disabled-password --ingroup vxlab --gecos '' vxlab
#RUN echo 'vxlab ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers


WORKDIR /root
ADD simstart simstart
RUN chmod +x simstart
COPY rosenv.sh rosenv.sh
ADD arm_track_sim arm_track_sim
RUN chmod +x arm_track_sim
COPY 2019-03-27-14-16-27.bag 2019-03-27-14-16-27.bag
COPY 2019-03-27-14-20-32.bag 2019-03-27-14-20-32.bag

