FROM ubuntu:latest
LABEL maintainer="ugo.pattacini@iit.it"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils software-properties-common apt-transport-https sudo \
    psmisc lsb-release tmux nano wget curl telnet gnupg build-essential gdb git gitk \
    cmake cmake-curses-gui libedit-dev libxml2-dev autoconf locales gdebi 

# Set the locale
RUN locale-gen en_US.UTF-8

# Install Hyper terminal
RUN wget -O hyper.deb https://releases.hyper.is/download/deb && \
    gdebi -n hyper.deb && \
    rm hyper.deb

# Install VSCode
# better off downling the deb file than relying on packages.microsoft.com sources that are often broken
RUN wget -O code.deb https://go.microsoft.com/fwlink/?LinkID=760868 && \
    gdebi -n code.deb && \
    rm code.deb

# Install graphics
RUN apt install -y xfce4 xfce4-goodies xserver-xorg-video-dummy xserver-xorg-legacy firefox && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
COPY xorg.conf /etc/X11/xorg.conf

# We need the most recent x11vnc
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && \
    apt update && \
    git clone https://github.com/LibVNC/x11vnc.git /opt/x11vnc && \
    cd /opt/x11vnc && \
    apt build-dep -y x11vnc && \
    autoreconf -fiv && \
    ./configure && \
    make && make install && \
    rm -Rf /opt/x11vnc

# Install Octave
RUN apt install -y octave epstool transfig

# Install python
RUN apt install -y python3 python3-dev python3-pip python3-setuptools

# Install websockify
RUN git clone https://github.com/novnc/websockify.git /opt/websockify && \
    cd /opt/websockify && \
    python3 setup.py install

# Clone noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    echo "<html><head><meta http-equiv=\"Refresh\" content=\"0; url=vnc.html\"></head></html>" > /opt/novnc/index.html

# Install dependencies
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    wget https://packages.osrfoundation.org/gazebo.key -O - | apt-key add - && \
    apt-add-repository -y ppa:dartsim/ppa && \
    apt update && \
    apt install -y libeigen3-dev build-essential cmake cmake-curses-gui coinor-libipopt-dev freeglut3-dev \
    libboost-system-dev libboost-filesystem-dev libboost-thread-dev libtinyxml-dev libace-dev libedit-dev \
    libgsl0-dev libopencv-dev libode-dev liblua5.1-dev lua5.1 git swig qtbase5-dev qtdeclarative5-dev \
    qtmultimedia5-dev qml-module-qtquick2 qml-module-qtquick-window2 qml-module-qtmultimedia \
    qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qt-labs-folderlistmodel \
    qml-module-qt-labs-settings libsdl1.2-dev libxml2-dev libv4l-dev \
    debhelper mesa-utils x11-utils cppcheck xsltproc python3-lxml python3-psutil bc netcat-openbsd gnupg2 \
    net-tools libfreeimage-dev libprotoc-dev libprotobuf-dev protobuf-compiler libcurl4-openssl-dev libtar-dev \
    libtbb-dev libogre-1.9-dev pkg-config libqwt-qt5-dev libltdl-dev libgts-dev libboost-program-options-dev \
    libboost-regex-dev libboost-iostreams-dev libignition-common3-dev libignition-fuel-tools4-dev \
    libignition-transport8-dev libignition-math6-dev libignition-msgs5-dev libtinyxml2-dev libsdformat9-dev \
    libbullet-dev libsimbody-dev libdart6-all-dev

# Select options
ARG BRANCH=devel
ARG BUILD_TYPE=Release
    
# Build gazebo
RUN git clone https://github.com/osrf/gazebo.git --depth 1 --branch gazebo11_11.0.0 && \
    cd gazebo && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    rm -Rf gazebo

# Install VTK
RUN git clone https://github.com/Kitware/VTK.git --depth 1 --branch v9.0.0 && \
    cd VTK && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTING=OFF && \
    make install && \
    rm -Rf VTK

# Build ycm
RUN git clone https://github.com/robotology/ycm.git --depth 1 && \
    cd ycm && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    rm -Rf ycm

# Build robot-testing-framework
RUN git clone https://github.com/robotology/robot-testing-framework.git --depth 1 --branch $BRANCH && \
    cd robot-testing-framework && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    rm -Rf robot-testing-framework

# Build yarp
RUN git clone https://github.com/robotology/yarp.git --depth 1 && \
    cd yarp && mkdir build && cd build && \
    cmake .. && make install && \
    rm -Rf yarp

# Build icub-main
RUN git clone https://github.com/robotology/icub-main.git --depth 1 --branch $BRANCH && \
    cd icub-main && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DENABLE_icubmod_cartesiancontrollerserver=ON \
    -DENABLE_icubmod_cartesiancontrollerclient=ON \
    -DENABLE_icubmod_gazecontrollerclient=ON && \
    make install && \
    rm -Rf icub-main

# Build idyntree
RUN git clone https://github.com/robotology/idyntree.git --depth 1 --branch $BRANCH && \
    cd idyntree && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    rm -Rf idyntree

# Build gazebo-yarp-plugins
RUN git clone https://github.com/robotology/gazebo-yarp-plugins.git --depth 1 --branch $BRANCH && \
    cd gazebo-yarp-plugins && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    rm -Rf gazebo-yarp-plugins

# Clone icub-models
RUN git clone https://github.com/robotology/icub-models.git --depth 1 --branch $BRANCH && \
    cd icub-models && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    rm -Rf icub-models

# Set environmental variables
ENV DISPLAY=:1
ENV ICUBcontrib_DIR=/workspace/iCubContrib
ENV YARP_DATA_DIRS=/usr/local/share/yarp:/usr/local/share/iCub:$ICUBcontrib_DIR/share/ICUBcontrib:/usr/local/share/iCub
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/yarp:/usr/local/lib/robottestingframework

# Create user gitpod
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Switch to gitpod user
USER gitpod

# Install Homebrew
RUN mkdir ~/.cache && sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
ENV PATH="${PATH}:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin/"
ENV MANPATH="${MANPATH}:/home/linuxbrew/.linuxbrew/share/man"
ENV INFOPATH="${INFOPATH}:/home/linuxbrew/.linuxbrew/share/info"
ENV HOMEBREW_NO_AUTO_UPDATE=1

# Set up .bashrc
WORKDIR /home/gitpod
RUN echo "unalias code 2>/dev/null" >> ~/.bashrc && \
    echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \$ '" >> ~/.bashrc && \
    echo "export PATH=${PATH}:${ICUBcontrib_DIR}/bin" >> ~/.bashrc && \
    echo "source /usr/local/share/gazebo/setup.sh" >> ~/.bashrc && \
    echo "export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:/usr/local/share:/usr/local/share/iCub/robots" >> ~/.bashrc

# Switch back to root
USER root

# Set up script to prepare /workspace/iCubContrib
COPY init-icubcontrib.sh /usr/bin/init-icubcontrib.sh
RUN chmod +x /usr/bin/init-icubcontrib.sh

# Set up script to launch graphics and vnc
COPY start-vnc-session.sh /usr/bin/start-vnc-session.sh
RUN chmod +x /usr/bin/start-vnc-session.sh

# Set up Hyper launcher
COPY Hyper.desktop /root/Desktop/Hyper.desktop
COPY Hyper.desktop /home/gitpod/Desktop/Hyper.desktop
RUN chmod +x /root/Desktop/Hyper.desktop && \
    chmod +x /home/gitpod/Desktop/Hyper.desktop

# Set up VSCode launcher
COPY ["Visual Studio Code.desktop", "/root/Desktop/Visual Studio Code.desktop"]
COPY ["Visual Studio Code.desktop", "/home/gitpod/Desktop/Visual Studio Code.desktop"]
RUN chmod +x "/root/Desktop/Visual Studio Code.desktop" && \
    chmod +x "/home/gitpod/Desktop/Visual Studio Code.desktop"

# Make sure specific dirs are owned by gitpod user
RUN chown -R gitpod.gitpod /home/gitpod/Desktop

# Manage x11vnc port
EXPOSE 5901

# Manage noVNC port
EXPOSE 6080

# Manage yarp port
EXPOSE 10000/tcp 10000/udp

# Launch bash from /workspace
WORKDIR /workspace
CMD ["bash"]
