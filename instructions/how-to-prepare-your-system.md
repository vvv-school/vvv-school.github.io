## Introduction

**Official installation instructions** can be found in our [**manual**](http://wiki.icub.org/wiki/ICub_Software_Installation).

However, for attending VVV school we do **support only Linux systems**, hence **we warmly suggest you to follow the installation guide** below (e.g. for a _Ubuntu_ distribution), which is in turn the way we prepared our **Virtual Machine**.

## Install dependencies
```sh
# YARP related dependencies
$ sudo sh -c 'echo "deb http://www.icub.org/ubuntu $(lsb_release -c | awk '"'"'{print $2}'"'"') contrib/science" > /etc/apt/sources.list.d/icub.list'
$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6
$ sudo apt-get update
$ sudo apt-get install icub-common

# ROS installation steps
$ sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -c | awk '"'"'{print $2}'"'"') main" > /etc/apt/sources.list.d/ros-latest.list'
$ sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
$ sudo apt-get update
$ sudo apt-get install ros-kinetic-desktop-full
$ sudo rosdep init
$ rosdep update

# ROS for NAO installation steps
$ sudo apt-get install ros-kinetic-nao-robot
$ sudo apt-get install ros-kinetic-nao-meshes
$ sudo apt-get install ros-kinetic-naoqi-dcm-driver
$ sudo apt-get install ros-kinetic-naoqi-bridge

# moveIT installation steps
$ sudo apt-get install ros-kinetic-moveit

# Caffe dependencies (cpu only installation). If you require CUDA, please install CUDA 8.0 & cuDNN beforehand.
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
```

**Note** `ros-desktop` package should have installed also the Gazebo simulator. If this is not the case, please install also the following package
```sh
$ sudo apt-get install gazebo7 libgazebo7-dev
```

## Matlab/Simulink
Some lessons, tutorials and assignments may require to have **Matlab** and **Simulink** installed.
If you do not have a valid licence, you can require a 30 days free trial directly at [Mathwork](https://it.mathworks.com/programs/trials/trial_request.html?prodcode=SL). Be sure to have access (or to require access) to the following Matlab products:
 - MATLAB
 - Simulink
 
If you have the freedom to choose a version, please select *R2016b*.

Full installation instructions for Matlab can be found [here](https://mathworks.com/help/install/ug/install-mathworks-software.html).
The following are a short extract, specialized for GNU/Linux of the full documentation.

Once you downloaded the correct installer, unzip it.
Open the terminal and move to the extracted folder and then execute the `install` script with administrator permissions:
```
$ sudo ./install
```

Follow the onscreen instructions. You have to login with your Mathwork account

![Image of mathwork login in installer](https://github.com/vvv-school/vvv-school.github.io/blob/master/images/instructions_matlab_install_login.png)

and when prompted select the correct license you requested (e.g. *Self Serve R2016b Trial* in the following image)

![Image of mathwork login in installer](https://github.com/vvv-school/vvv-school.github.io/blob/master/images/instructions_matlab_install_license.png)

Finilize the installation following the onscreen instructions and by adding the simlink in `/usr/local/bin`.

## Setup environment variables
We assume that you have the following directories available in your home path:
- `~/robot-code`
- `~/robot-install`

You can then create the file `~/.bashrc-dev` containing the following instructions:
```sh
# to enhance git experience in the console ;)
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[00;32m\]$(__git_ps1'

export ROBOT_CODE=~/robot-code
export ROBOT_INSTALL=~/robot-install

# ros
source /opt/ros/kinetic/setup.bash
export ROS_MASTER_URI=https://localhost:11311
# instead, if you need to communicate with an external machine, use:
# export ROS_MASTER_URI=http://[NAME_OF_MACHINE_RUNNING_ROSCORE_HERE]:11311"
# and add in /etc/hosts name and ip of all the machines in the ros network

# caffe configuration
export Caffe_ROOT=${ROBOT_CODE}/caffe

# liblinear
export LIBSVMLIN_DIR=${ROBOT_CODE}/himrep/liblinear-1.91

# gazebo plugins and model
export GAZEBO_PLUGIN_PATH=${ROBOT_CODE}/codyco-superbuild/build/install/lib
export GAZEBO_MODEL_PATH=${ROBOT_CODE}/codyco-superbuild/build/install/share/gazebo/models

# matlab
export MATLABPATH=${ROBOT_CODE}/codyco-superbuild/build/install/mex:${ROBOT_CODE}/codyco-superbuild/build/install/share/WB-Toolbox:${ROBOT_CODE}/codyco-superbuild/build/install/share/WB-Toolbox/images

export PATH=${PATH}:${ROBOT_INSTALL}/bin:${ROBOT_CODE}/codyco-superbuild/build/install/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROBOT_INSTALL}/lib
export YARP_DATA_DIRS=${ROBOT_INSTALL}/share/yarp:${ROBOT_INSTALL}/share/iCub:${ROBOT_INSTALL}/share/ICUBcontrib:${ROBOT_CODE}/codyco-superbuild/build/install/share/codyco
```
Finally, do:
```sh
$ echo "source ~/.bashrc-dev" >> ~/.bashrc
```
And restart the `bash`.

## Setup Yarp autocompletion
```sh
$ sudo ln -s $ROBOT_CODE/yarp/scripts/yarp_completion /etc/bash_completion.d/yarp_completion
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
$ git clone https://github.com/robotology-playground/event-driven.git
$ git clone https://www.github.com/BVLC/caffe.git
$ cd caffe
$ git checkout b2982c7eef65a1b94db6f22fb8bb7caa986e6f29
$ cd ../
$ git clone https://github.com/robotology/himrep.git
```

## Install the code

### Install Yarp
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

### Install Caffe
```sh
$ cd $ROBOT_CODE/caffe
$ mkdir build && cd build
$ cmake -DBLAS=Open ../
$ make all
$ make runtest
$ make install
$ cd ../
$ ./scripts/download_model_binary.py models/bvlc_reference_caffenet
$ ./data/ilsvrc12/get_ilsvrc_aux.sh
```

### Install codyco-superbuild
```sh
$ cd $ROBOT_CODE/codyco-superbuild
$ mkdir build && cd build
$ cmake -DCODYCO_USES_GAZEBO:BOOL=ON ../
$ make
```

### Install event-driven
```sh
$ cd $ROBOT_CODE/event-driven
$ mkdir build && cd build
$ cmake -DV_10BITCODEC:BOOL=ON -DOpenCV_DIR=/usr/share/OpenCV ../
$ make install
```

### Install himrep
```sh
$ cd $ROBOT_CODE/himrep
$ cd liblinear-1.91
$ cmake ./
$ make
$ cd ../
$ mkdir build && cd build
$ cmake ../
$ make install

# import and setup configuration file
$ yarp-config context --import himrep imagenet_val_cutfc6.prototxt

# Edit the imported file ~/.local/share/yarp/contexts/himrep/imagenet_val_cutfc6.prototxt
# to modify the absolute path to the mean image and make it point to ${Caffe_ROOT}/data/ilsvrc12/imagenet_mean.binaryproto 
# replacing ${Caffe_ROOT} with its actual value
```

## Download datasets
```sh
$ cd $ROBOT_CODE
$ mkdir datasets && cd datasets
$ wget http://www.icub.org/download/software/datasetplayer-demo/testData_20120803_095402.zip
$ unzip testData_20120803_095402.zip
```
