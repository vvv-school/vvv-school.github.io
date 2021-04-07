FROM ubuntu:latest
LABEL org.opencontainers.image.title="VVV School Gitpod Docker Image"
LABEL org.opencontainers.image.description="Stack of components required to run VVV School assignments on Gitpod"
LABEL org.opencontainers.image.source="https://github.com/vvv-school/vvv-school.github.io"
LABEL org.opencontainers.image.authors="Ugo Pattacini <ugo.pattacini@iit.it>"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils software-properties-common apt-transport-https sudo \
    psmisc lsb-release tmux nano wget curl telnet gnupg build-essential gdb git gitk \
    cmake cmake-curses-gui libedit-dev libxml2-dev autoconf locales gdebi terminator meld \
    dos2unix bash-completion

# Set the locale
RUN locale-gen en_US.UTF-8

# Install VSCode
# better off downling the deb file than relying on packages.microsoft.com sources that are often broken
RUN wget -O code.deb https://go.microsoft.com/fwlink/?LinkID=760868 && \
    gdebi -n code.deb && \
    rm code.deb

# Install graphics
RUN apt install -y xfce4 xfce4-goodies xserver-xorg-video-dummy xserver-xorg-legacy x11vnc firefox && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
COPY xorg.conf /etc/X11/xorg.conf
RUN dos2unix /etc/X11/xorg.conf

# Install Octave
RUN apt install -y octave epstool transfig

# Install python
RUN apt install -y python3 python3-dev python3-pip python3-setuptools && \
    if [ ! -f "/usr/bin/python" ]; then ln -s /usr/bin/python3 /usr/bin/python; fi
    
# Install magic-wormwhole to get things from one computer to another safely
RUN apt install -y magic-wormhole

# Install noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    echo "<html><head><meta http-equiv=\"Refresh\" content=\"0; url=vnc.html?autoconnect=true&reconnect=true&reconnect_delay=1000&resize=scale&quality=9\"></head></html>" > /opt/novnc/index.html

# Install dependencies
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    wget https://packages.osrfoundation.org/gazebo.key -O - | apt-key add - && \
    apt update && \
    apt install -y libeigen3-dev build-essential cmake cmake-curses-gui coinor-libipopt-dev freeglut3-dev \
    libboost-system-dev libboost-filesystem-dev libboost-thread-dev libtinyxml-dev libace-dev libedit-dev \
    libgsl0-dev libopencv-dev libode-dev liblua5.1-dev lua5.1 git swig qtbase5-dev qtdeclarative5-dev \
    qtmultimedia5-dev qml-module-qtquick2 qml-module-qtquick-window2 qml-module-qtmultimedia \
    qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qt-labs-folderlistmodel \
    qml-module-qt-labs-settings libsdl1.2-dev libxml2-dev libv4l-dev \
    gazebo11 libgazebo11-dev

# Select options
ARG BRANCH=devel
ARG BUILD_TYPE=Release

# Install VTK
RUN git clone https://github.com/Kitware/VTK.git --depth 1 --branch v9.0.1 && \
    cd VTK && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTING=OFF && \
    make install && \
    cd ../.. && rm -Rf VTK

# Build ycm
RUN git clone https://github.com/robotology/ycm.git --depth 1 && \
    cd ycm && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    cd ../.. && rm -Rf ycm

# Build robot-testing-framework
RUN git clone https://github.com/robotology/robot-testing-framework.git --depth 1 --branch $BRANCH && \
    cd robot-testing-framework && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    cd ../.. && rm -Rf robot-testing-framework

# Build yarp
RUN git clone https://github.com/robotology/yarp.git --depth 1 && \
    cd yarp && mkdir build && cd build && \
    cmake .. && make install && \
    cd ../.. && rm -Rf yarp

# Build icub-main
RUN git clone https://github.com/robotology/icub-main.git --depth 1 --branch $BRANCH && \
    cd icub-main && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DENABLE_icubmod_cartesiancontrollerserver=ON \
    -DENABLE_icubmod_cartesiancontrollerclient=ON \
    -DENABLE_icubmod_gazecontrollerclient=ON && \
    make install && \
    cd ../.. && rm -Rf icub-main

# Build idyntree
RUN git clone https://github.com/robotology/idyntree.git --depth 1 --branch $BRANCH && \
    cd idyntree && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    cd ../.. && rm -Rf idyntree

# Build gazebo-yarp-plugins
RUN git clone https://github.com/robotology/gazebo-yarp-plugins.git --depth 1 --branch $BRANCH && \
    cd gazebo-yarp-plugins && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    cd ../.. && rm -Rf gazebo-yarp-plugins

# Clone icub-models
RUN git clone https://github.com/robotology/icub-models.git --depth 1 --branch $BRANCH && \
    cd icub-models && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    cd ../.. && rm -Rf icub-models

# Set environmental variables
ENV DISPLAY=:1
ENV ICUBcontrib_DIR=/workspace/iCubContrib
ENV DATASETS_PATH=/workspace/datasets
ENV YARP_DATA_DIRS=/usr/local/share/yarp:/usr/local/share/iCub:${ICUBcontrib_DIR}/share/ICUBcontrib
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/yarp:/usr/local/lib/robottestingframework:${ICUBcontrib_DIR}/lib

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

# Install informative git for bash
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

# Set up .bashrc
# "/usr/bin" needs to come in the first place within PATH to shadow "/ide/bin/code"
WORKDIR /home/gitpod
RUN echo "GIT_PROMPT_ONLY_IN_REPO=1" >> ~/.bashrc && \
    echo "source \${HOME}/.bash-git-prompt/gitprompt.sh" >> ~/.bashrc && \
    echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc && \
    echo "export GAZEBO_RESOURCE_PATH=\${GAZEBO_RESOURCE_PATH}:\${ICUBcontrib_DIR}/share/gazebo/worlds" >> ~/.bashrc && \
    echo "export GAZEBO_MODEL_PATH=\${GAZEBO_MODEL_PATH}:/usr/local/share:/usr/local/share/iCub/robots:\${ICUBcontrib_DIR}/share/gazebo/models" >> ~/.bashrc && \
    echo "export PATH=/usr/bin:\${PATH}:\${ICUBcontrib_DIR}/bin" >> ~/.bashrc

# Switch back to root
USER root

# Set up script to prepare /workspace/iCubContrib
COPY init-icubcontrib.sh /usr/bin/init-icubcontrib.sh
RUN chmod +x /usr/bin/init-icubcontrib.sh && \
    dos2unix /usr/bin/init-icubcontrib.sh

# Set up script to launch graphics and vnc
COPY start-vnc-session.sh /usr/bin/start-vnc-session.sh
RUN chmod +x /usr/bin/start-vnc-session.sh && \
    dos2unix /usr/bin/start-vnc-session.sh

# Set up VSCode launcher
COPY ["Visual Studio Code.desktop", "/home/gitpod/Desktop/Visual Studio Code.desktop"]
RUN chmod +x "/home/gitpod/Desktop/Visual Studio Code.desktop" && \
    dos2unix "/home/gitpod/Desktop/Visual Studio Code.desktop"

# Make sure specific dirs are owned by gitpod user
RUN chown -R gitpod.gitpod /home/gitpod/Desktop

# Manage x11vnc port
EXPOSE 5901

# Manage noVNC port
EXPOSE 6080

# Manage yarp port
EXPOSE 10000/tcp 10000/udp

# Clean up unnecessary installation products
RUN rm -Rf /var/lib/apt/lists/*

# Launch bash from /workspace
WORKDIR /workspace
CMD ["bash"]
