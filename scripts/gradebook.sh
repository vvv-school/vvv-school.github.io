#!/bin/bash

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.

# Dependencies (through apt-get):
# - curl
# - jq

if [ $# -lt 2 ]
then
    echo "Usage: $0 <organization> <path-to-gradebook>"
    exit 1
fi

org=$1
path=$2

data=$path/data.json
gradebook=$path/gradbook.json

red='\033[1;31m'
green='\033[1;32m'
blue='\033[1;34m'
cyan='\033[1;36m'
nc='\033[0m'

if [ ! -f "$data" ]; then
    echo -e "${red}Unable to find ${data}${nc}\n"
    exit 2
fi

students=$(cat $data | jq '.students | .[]' | sed 's/\"//g')
repositories=$(curl -s https://api.github.com/orgs/$org/repos?type=public | jq '.[] | .name' | sed 's/\"//g')

echo -e "\nWorking out the students:\n${green}${students}${nc}\n"
echo -e "Against the repositories:\n${blue}${repositories}${nc}\n"

