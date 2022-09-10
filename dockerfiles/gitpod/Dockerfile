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
    psmisc tmux nano wget curl telnet gnupg gdb git gitk autoconf locales gdebi \
    terminator meld dos2unix meshlab iputils-ping

# Set the locale
RUN locale-gen en_US.UTF-8

# Install VSCode
# better off downling the deb file than relying on packages.microsoft.com sources that are often broken
RUN wget -O code.deb https://go.microsoft.com/fwlink/?LinkID=760868 && \
    gdebi -n code.deb && \
    rm code.deb

# Install graphics
RUN apt install -y xfce4 xfce4-goodies xserver-xorg-video-dummy xserver-xorg-legacy x11vnc firefox && \
    apt remove -y xfce4-power-manager xfce4-screensaver light-locker && \
    apt autoremove -y && \
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

# Select options
ARG ROBOTOLOGY_SUPERBUILD_RELEASE
ARG BUILD_TYPE
ARG ROBOTOLOGY_SUPERBUILD_INSTALL_DIR=/usr/local

# Set up git (required by superbuild)
RUN git config --global user.name "GitHub Actions" && \
    git config --global user.email "actions@github.com"

# Install dependencies
RUN git clone https://github.com/robotology/robotology-superbuild.git --depth 1 --branch ${ROBOTOLOGY_SUPERBUILD_RELEASE} && \
    robotology-superbuild/scripts/install_apt_dependencies.sh
    
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    wget https://packages.osrfoundation.org/gazebo.key -O - | tee /etc/apt/trusted.gpg.d/gazebo.asc && \
    apt update && \
    apt install -y libcgal-dev gazebo libgazebo-dev

# Install VTK
RUN git clone https://github.com/Kitware/VTK.git --depth 1 --branch v9.1.0 && \
    cd VTK && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DBUILD_TESTING=OFF && \
    make install && \
    cd ../.. && rm -Rf VTK

# Build robotology-superbuild
RUN cd robotology-superbuild && mkdir build && cd build && \
    cmake .. \
          -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
          -DYCM_EP_INSTALL_DIR=${ROBOTOLOGY_SUPERBUILD_INSTALL_DIR} \
          -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
          -DROBOTOLOGY_ENABLE_ROBOT_TESTING:BOOL=ON \
          -DROBOTOLOGY_USES_GAZEBO:BOOL=ON && \
    make && \
    cd ../.. && rm -Rf robotology-superbuild

# Clean up git configuration
RUN git config --global --unset-all user.name && \
    git config --global --unset-all user.email

# Set environmental variables
ENV DISPLAY=:1

# Create user gitpod
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Switch to gitpod user
USER gitpod

# Install informative git for bash
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

# Set up .bashrc
WORKDIR /home/gitpod
RUN echo "GIT_PROMPT_ONLY_IN_REPO=1" >> ~/.bashrc && \
    echo "source \${HOME}/.bash-git-prompt/gitprompt.sh" >> ~/.bashrc && \
    echo "YARP_COLORED_OUTPUT=1" >> ~/.bashrc && \
    echo "source ${ROBOTOLOGY_SUPERBUILD_INSTALL_DIR}/share/robotology-superbuild/setup.sh" >>  ~/.bashrc

# Switch back to root
USER root

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

# Manage ports
EXPOSE 5901 6080 10000/tcp 10000/udp

# Clean up unnecessary installation products
RUN rm -Rf /var/lib/apt/lists/*

# Launch bash from /workspace
WORKDIR /workspace
CMD ["bash"]
