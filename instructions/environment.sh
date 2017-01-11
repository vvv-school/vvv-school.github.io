# you could "source" this file from your .bashrc

# we assume you have available these two repositories in your home:
# ~/robot-code
# ~/robot-install

export ROBOT_CODE=~/robot-code
export ROBOT_INSTALL=~/robot-install

export PATH=${PATH}:${ROBOT_INSTALL}/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROBOT_INSTALL}/lib
export YARP_DATA_DIRS=${ROBOT_INSTALL}/share/yarp:${ROBOT_INSTALL}/share/iCub:${ROBOT_INSTALL}/share/ICUBcontrib
