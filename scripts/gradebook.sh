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

if [ ! -f "$data" ]; then
    echo "Unable to find $data"
    exit 2
fi

students=$(cat $data | jq '.students | .[]' | sed 's/\"//g')

echo $students
