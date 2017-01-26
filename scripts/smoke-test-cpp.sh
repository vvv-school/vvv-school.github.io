#!/bin/bash

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.

if [ $# -lt 3 ]; then
    echo "Usage: $0 <abspath-to-build> <abspath-to-code> <abspath-to-test>"
    exit 4
fi

build_dir=$1
code_dir=$2
test_dir=$3
cur_dir=$(pwd)

cd $build_dir
if [ -d build-code ]; then 
    rm -Rf build-code
fi
mkdir build-code && cd build-code
cmake -DCMAKE_BUILD_TYPE=Release $code_dir
if [ $? -ne 0 ]; then
   cd $cur_dir
   exit 2
fi
make install
if [ $? -ne 0 ]; then
   cd $cur_dir
   exit 2
fi
cd ../

if [ -d build-test ]; then 
    rm -Rf build-test
fi
rm -Rf build-test
mkdir build-test && cd build-test
cmake -DCMAKE_BUILD_TYPE=Release $test_dir
if [ $? -ne 0 ]; then
   cd $cur_dir
   exit 3
fi
make
if [ $? -ne 0 ]; then
   cd $cur_dir
   exit 3
fi
cd ../

# to let yarpmanager access the fixture
if [ -z "$YARP_DATA_DIRS" ]; then
   export YARP_DATA_DIRS=$test_dir
else
   export YARP_DATA_DIRS=${YARP_DATA_DIRS}:$test_dir
fi

# to make the test library retrievable
if [ -z "$LD_LIBRARY_PATH" ]; then
   export LD_LIBRARY_PATH=$build_dir/build-test/plugins
else
   export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$build_dir/build-test/plugins
fi

yarp where
if [ $? -eq 0 ]; then
   kill_yarp="no"
else
   kill_yarp="yes"   
   yarpserver --write &
   sleep 1
fi

yarp exists /testnode
if [ $? -eq 0 ]; then
   kill_testnode="no"
else
   kill_testnode="yes"
   yarprun --server /testnode &
   sleep 1
fi

if [ -f ${test_dir}/pre-test.sh ]; then
    tmp_dir=$(pwd)
    cd $test_dir
    ./pre-test.sh
    cd $tmp_dir
fi

testrunner --verbose --suit $test_dir/test.xml

if [ -f ${test_dir}/post-test.sh ]; then
    tmp_dir=$(pwd)
    cd $test_dir
    ./post-test.sh
    cd $tmp_dir
fi

if [ "$kill_testnode" == "yes" ]; then
   killall -9 yarprun
fi

if [ "$kill_yarp" == "yes" ]; then
   killall -9 yarpserver
fi

cd build-code
make uninstall
cd ../

# color codes
red='\033[1;31m'
green='\033[1;32m'
nc='\033[0m'

npassed=0
nfailed=0
if [ -f result.txt ]; then
    cat result.txt
    npassed=$(awk '/Number of passed test cases/{print $7}' result.txt)
    nfailed=$(awk '/Number of failed test cases/{print $7}' result.txt)
else
    echo -e "${red}Unable to get test result${nc}\n"    
fi

cd $cur_dir
if [ $npassed -eq 0 ] || [ $nfailed -gt 0 ]; then
   echo -e "${red}xxxxx Test FAILED xxxxx${nc}\n"
   exit 1
else
   echo -e "${green}===== Test PASSED =====${nc}\n"
   exit 0
fi

