## Preamble

**Official installation instructions** can be found in our [**manual**](http://wiki.icub.org/wiki/ICub_Software_Installation).

Nonetheless, here's a **guide we suggest to follow** for installation on _Linux_ systems (e.g. for a _Ubuntu Xenial_ distribution), which is in turn the way we prepared our **Virtual Machine**.

## Install depedencies
```sh
# YARP related dependencies
$ sudo sh -c 'echo "deb http://www.icub.org/ubuntu xenial contrib/science" > /etc/apt/sources.list.d/icub.list'
$ sudo apt-get update
$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6
$ sudo apt-get install icub-common

# ROS installation steps
$ sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list'
$ sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
$ sudo apt-get update
$ sudo apt-get install ros-kinetic-desktop-full
$ sudo rosdep init
$ rosdep update
$ echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
$ echo "export ROS_MASTER_URI=http://localhost:11311" >> ~/.bashrc

# if you need to comminicate with external machine, define the names:
$ echo "export ROS_MASTER_URI=http://[NAME_OF_MACHINE_RUNNING_ROSCORE_HERE]:11311" >> ~/.bashrc
# add in /etc/hosts name and ip of all the machines in the ros network
# restart bash

# moveIT installation steps
$ sudo apt-get install ros-kinetic-moveit
```

## Setup environment variables
```sh
# you could "source" this file from your .bashrc
# we assume you have available these two repositories in your home:
# ~/robot-code
# ~/robot-install

# to enhance git experience in the console ;)
if [ "$color_prompt" == "yes" ]; then
   PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[00;32m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ '
else
   PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(__git_ps1 " (%s)")\$ '
fi

export ROBOT_CODE=~/robot-code
export ROBOT_INSTALL=~/robot-install

export PATH=${PATH}:${ROBOT_INSTALL}/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROBOT_INSTALL}/lib
export YARP_DATA_DIRS=${ROBOT_INSTALL}/share/yarp:${ROBOT_INSTALL}/share/iCub:${ROBOT_INSTALL}/share/ICUBcontrib
```

## Get the code
```sh
$ cd $ROBOT_CODE
$ git clone https://github.com/robotology/yarp.git
$ git clone https://github.com/robotology/icub-main.git
$ git clone https://github.com/robotology/icub-contrib-common.git
$ git clone https://github.com/robotology/robot-testing.git
```

## Install the code

### Install yarp
```sh
$ cd $ROBOT_CODE/yarp
$ mkdir build && cd build
$ cmake -DCMAKE_INSTALL_PREFIX=$ROBOT_INSTALL -DCREATE_GUIS=ON -DCREATE_LIB_MATH=ON ../
$ make install
```

### Install icub-main
```sh
$ cd $ROBOT_CODE/icub-main
$ mkdir build && cd build
$ cmake -DCMAKE_INSTALL_PREFIX=$ROBOT_INSTALL -DENABLE_icubmod_cartesiancontrollerserver=ON -DENABLE_icubmod_cartesiancontrollerclient=ON -DENABLE_icubmod_gazecontrollerclient=ON ../
$ make install
```

### Install icub-contrib-common
```sh
$ cd $ROBOT_CODE/icub-contrib-common
$ mkdir build && cd build
$ cmake -DCMAKE_INSTALL_PREFIX=$ROBOT_INSTALL ../
$ make install
```

### Install robot-testing
```sh
$ cd $ROBOT_CODE/robot-testing
$ mkdir build && cd build
$ cmake -DCMAKE_INSTALL_PREFIX=$ROBOT_INSTALL -DENABLE_MIDDLEWARE_PLUGINS=ON ../
$ make install
```
