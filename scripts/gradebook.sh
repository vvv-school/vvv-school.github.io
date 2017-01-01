#!/bin/bash

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.

# Dependencies (through apt-get):
# - curl
# - jq

if [ $# -lt 3 ]; then
    echo "Usage: $0 <organization> <path-to-gradebook> <build-dir> [--loop]"
    exit 1
fi

# trap ctrl-c and call ctrl_c()
trap ctrl_c SIGINT SIGTERM

function ctrl_c() {
    echo -e "${red}Trapped CTRL-C${nc}"
}

org=$1
path=$2

if [ ! -d "$3" ]; then
    mkdir $3
fi
cd "$3"

loop=false
if [ $# -gt 3 ]; then
    if [ "$4" == "--loop"]; then
        loop=true
    fi
fi

data=$path/data.json
cur_gradebook=$path/gradbook.json
new_gradebook=new-gradbook.json

if [ ! -f "$data" ]; then
    echo -e "${red}Unable to find ${data}${nc}\n"
    exit 2
fi

# color codes
red='\033[1;31m'
green='\033[1;32m'
blue='\033[1;34m'
cyan='\033[1;36m'
nc='\033[0m'

# GitHub symbols
status_passed=":white_check_mark:"
status_failed=":x:"

students=$(cat $data | jq '.students | .[]' | sed 's/\"//g')
tutorials=$(cat $data | jq '.tutorials | .[] | .name' | sed 's/\"//g')
assignments=$(cat $data | jq '.assignments | .[] | .name' | sed 's/\"//g')

while true; do
    repositories=$(curl -s https://api.github.com/orgs/$org/repos?type=public | jq '.[] | .name' | sed 's/\"//g')
    
    echo -e "Working out the students:\n${green}${students}${nc}\n"
    echo -e "Against repositories in ${cyan}$org:\n${blue}${repositories}${nc}\n"

    for stud in $students; do
        echo -e "${cyan}Grading ${stud}${nc}"
        cur_stud_assignments="[null]"
        if [ -f $cur_gradebook ]; then
            cur_stud_assignments=$(cat $cur_gradebook | jq '. | map(select(.username == "$stud")) | .[0] | .assignments')
        fi 
        
        for repo in $repositories; do
            proceed=false;
            
            for tuto in $tutorials; do
                if [ "${repo}" == "${tuto}-${stud}" ]; then
                    echo -e "${cyan}${repo} is a tutorial${nc} => given for granted ;)"
                    score=$(cat $data | jq '.tutorials | .[] | .score' | sed 's/\"//g')
                    echo -e "${blue}score = ${score}${nc}"
                    proceed=true
                    break
                fi
            done
            
            if [ "$proceed" == true ]; then
                continue
            fi
                    
            for assi in $assignments; do
                if [ "${repo}" == "${assi}-${stud}" ]; then
                    echo -e "${cyan}${repo} is an assignment${nc}"
                    cur_stud_assi=$(echo "$cur_stud_assigments" | jq '. | map(select(.name == "$repo")) | .[0]')
                    last_commit_date=$(echo "$cur_stud_assi" | jq '.last_commit_date')
                    repo_commit_date=$(curl -s https://api.github.com/repos/vvv-school/$repo/commits | jq '.[0] | .commit | .committer | .date')
                    if [ "${last_commit_date}" == "${repo_commit_date}" ]; then
                        echo "detected new activity on the repository => proceeding with testing"
                    fi
                    break
                fi
            done
        done
    done
    
    if [ "$loop" == false ]; then
        break
    fi
done

