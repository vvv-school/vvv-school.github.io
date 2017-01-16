## Introduction

**Official installation instructions** can be found in our [**manual**](http://wiki.icub.org/wiki/ICub_Software_Installation).

However, for attending VVV school we do **support only Linux systems**, hence **we warmly suggest you to follow the installation guide** below (e.g. for a _Ubuntu Xenial_ distribution), which is in turn the way we prepared our **Virtual Machine**.

## Install dependencies
```sh
# YARP related dependencies
$ sudo sh -c 'echo "deb http://www.icub.org/ubuntu xenial contrib/science" > /etc/apt/sources.list.d/icub.list'
$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6
$ sudo apt-get update
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

# instead, if you need to communicate with external machine, define the names:
$ echo "export ROS_MASTER_URI=http://[NAME_OF_MACHINE_RUNNING_ROSCORE_HERE]:11311" >> ~/.bashrc
# add in /etc/hosts name and ip of all the machines in the ros network
# restart bash

# moveIT installation steps
$ sudo apt-get install ros-kinetic-moveit

# Caffe (cpu only installation). If you require CUDA please install CUDA 8.0 & cuDNN beforehand.

# Caffe dependencies
# OpenBLAS
$ sudo apt-get install libopenblas-dev
# boost
$ sudo apt-get install libboost-all-dev
# Google Protobuf Buffers C++
$ sudo apt-get install libprotobuf-dev protobuf-compiler
# Google Logging
$ sudo apt-get install libgoogle-glog-dev
# Google Flags
$ sudo apt-get install libgflags-dev
# LevelDB
$ sudo apt-get install libleveldb-dev
# HDF5
$ sudo apt-get install libhdf5-serial-dev
# LMDB
$ sudo apt-get install liblmdb-dev
# snappy:
$ sudo apt-get install libsnappy-dev

# Caffe libraries
$ git clone https://www.github.com/BVLC/caffe.git
$ cd caffe
$ git checkout b2982c7eef65a1b94db6f22fb8bb7caa986e6f29

# Caffe compilation
$ cd caffe
$ mkdir build
$ cd build
$ ccmake ../ (set BLAS to open or Open)
$ make all
$ make runtest
$ make install

# Caffe configuration
# Set the Caffe_ROOT environment variable to your Caffe's source root directory.
$ cd $Caffe_ROOT && scripts/download_model_binary.py models/bvlc_reference_caffenet
$ cd $Caffe_ROOT && ./data/ilsvrc12/get_ilsvrc_aux.sh
$ yarp-config context --import himrep imagenet_val_cutfc6.prototxt
# Open the imported file imagenet_val_cutfc6.prototxt and modify the absolute path to the mean image
# this path should be $Caffe_ROOT/data/ilsvrc12/imagenet_mean.binaryproto 
# with the value of $Caffe_ROOT on your machine substituted

# Hierarchical Image Representation
$ git clone https://github.com/robotology/himrep.git
$ cd himrep
$ cd liblinear-1.91
$ cmake .
$ make
$ cd ..
$ mkdir build
$ cd build
$ make 
$ make install
```

**Note** `ros-desktop` package should have installed also the Gazebo simulator. If this is not the case, please install also the following package
```sh
$ sudo apt-get install gazebo7 libgazebo7-dev
```

## Matlab/Simulink
Some lessons, tutorials and assignments may require to have **Matlab** and **Simulink** installed.
If you do not have a valid licence, you can require a 30 days free trial directly at [Mathwork](https://it.mathworks.com/programs/trials/trial_request.html?prodcode=SL). Be sure to have access to the following Matlab products:
 - MATLAB
 - Simulink
 
If you have the freedom to choose a version, please select *R2016b*.

## Setup environment variables
```sh
# we assume you have available these two repositories in your home:
# ~/robot-code
# ~/robot-install

# to enhance git experience in the console ;)
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[00;32m\]$(__git_ps1'

export ROBOT_CODE=~/robot-code
export ROBOT_INSTALL=~/robot-install

export PATH=${PATH}:${ROBOT_INSTALL}/bin:${ROBOT_CODE}/codyco-superbuild/build/install/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROBOT_INSTALL}/lib
export YARP_DATA_DIRS=${ROBOT_INSTALL}/share/yarp:${ROBOT_INSTALL}/share/iCub:${ROBOT_INSTALL}/share/ICUBcontrib:${ROBOT_CODE}/codyco-superbuild/build/install/share/codyco

# gazebo plugins and model
export GAZEBO_PLUGIN_PATH=${ROBOT_CODE}/codyco-superbuild/build/install/lib
export GAZEBO_MODEL_PATH=${ROBOT_CODE}/codyco-superbuild/build/install/share/gazebo/models
```

## Setup git configuration
In order to install the `codyco-superbuild` software you must have git configured on your machine. If you have already performed the following steps, you can jump to the next section.
```sh
$ git config --global user.name "[firstname lastname]"
$ git config --global user.email "[valid email]"
$ git config --global color.pager true
$ git config --global color.ui auto
```

## Get the code
```sh
$ cd $ROBOT_CODE
$ git clone https://github.com/robotology/yarp.git
$ git clone https://github.com/robotology/icub-main.git
$ git clone https://github.com/robotology/icub-contrib-common.git
$ git clone https://github.com/robotology/robot-testing.git
$ git clone https://github.com/robotology/codyco-superbuild.git
```

## Install the code

### Install yarp
```sh
$ cd $ROBOT_CODE/yarp
$ mkdir build && cd build
$ cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$ROBOT_INSTALL -DCREATE_GUIS=ON -DCREATE_LIB_MATH=ON ../
$ make install
```

### Install icub-main
```sh
$ cd $ROBOT_CODE/icub-main
$ mkdir build && cd build
$ cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$ROBOT_INSTALL -DENABLE_icubmod_cartesiancontrollerserver=ON -DENABLE_icubmod_cartesiancontrollerclient=ON -DENABLE_icubmod_gazecontrollerclient=ON ../
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
$ cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$ROBOT_INSTALL -DENABLE_MIDDLEWARE_PLUGINS=ON ../
$ make install
```

### Install codyco-superbuild
```sh
$ cd $ROBOT_CODE/codyco-superbuild
$ mkdir build && cd build
$ cmake .. -DCODYCO_USES_GAZEBO:BOOL=ON
$ make
```
