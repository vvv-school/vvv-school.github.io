#!/bin/bash

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.

# Dependencies (through apt-get):
# - curl
# - jq

if [ $# -lt 3 ]; then
    echo "Usage: $0 <organization> <path-to-gradebook> <build-dir>"
    exit 1
fi

org=$1
path=$2

if [ ! -d "$3" ]; then
    mkdir $3
fi
cd "$3"

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

function smoke_test()
{
    if [ -d "$1" ]; then
        rm $1 -rf
    fi
 
    local ret="error"
    git clone $2
    if [ $? -eq 0 ]; then        
        if [ -d "$1/smoke-test" ]; then
            cd $1/smoke-test
            ret=$(./test.sh)
        else
            echo -e "${red}$1 does not contain smoke-test${nc}" > /dev/stderr
        fi
    else
        echo -e "${red}GitHub seems unreachable${nc}" > /dev/stderr
    fi

    echo $ret
}

students=$(cat $data | jq '.students | .[]' | sed 's/\"//g')
tutorials=$(cat $data | jq '.tutorials | .[] | .name' | sed 's/\"//g')
assignments=$(cat $data | jq '.assignments | .[] | .name' | sed 's/\"//g')

# compute the score of the student
# counting tutorials and assignments
function update_score {
    stud=$1
}

function publish_gradebook {
    # git diff --exit-code
    # if [ $? -ne 0 ]; then
    #   generate README.md
    # fi
}

# update tutorial in the new gradebook
function update_tutorial {
    stud=$1
    repo=$2
    
    echo -e "${cyan}${repo} is a tutorial${nc} => given for granted ;)" > /dev/stderr
    
    if [ -f $new_gradebook ]; then
        rm $new_gradebook
    fi

    jq_path=$(cat gradebook.json | jq 'paths(.name?=="$repo")')
    if [ ! -z "$jq_path" ]; then
        cat $cur_gradebook | jq 'setpath([$jq_path,"status"];$status_passed)' > $new_gradebook
    else        
        jq_path_student=$(cat gradebook.json | jq 'paths(.username?=="$stud")')        
        if [ ! -z "$jq_path_student" ]; then
            jq_path_tutorial=$(cat $cur_gradebook | jq '.[] | select(.username=="$stud") | .tutorials | length+1')
        else
            jq_path_student=$(cat $cur_gradebook | jq 'length+1')
            jq_path_tutorial=0
        fi
        cat $cur_gradebook | jq 'setpath([$jq_path_student,"tutorials",$jq_path_tutorial,"name"];$repo) |\
                                 setpath([$jq_path_student,"tutorials",$jq_path_tutorial,"status"];$status_pased)' > $new_gradebook
    fi
    
    update_score ${stud}
}

function ctrl_c() {
    echo -e "${red}Trapped CTRL-C${nc}"
    exit 0
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c SIGINT

while true; do
    repositories=$(curl -s https://api.github.com/orgs/$org/repos?type=public | jq '.[] | .name' | sed 's/\"//g')
    
    echo -e "Working out the students:\n${green}${students}${nc}\n"
    echo -e "Against repositories in ${cyan}${org}:\n${blue}${repositories}${nc}\n"

    # for each student in the list
    for stud in $students; do
        echo -e "${cyan}Grading ${stud}${nc}"
        cur_stud_assignments="[null]"
        if [ -f $cur_gradebook ]; then
            cur_stud_assignments=$(cat $cur_gradebook | jq '. | map(select(.username == "$stud")) | .[0] | .assignments')
        fi 
            
        # for each repository found within the organization
        for repo in $repositories; do
            proceed=false;
            
            # for tutorials, simply give them for granted
            for tuto in $tutorials; do
                if [ "${repo}" == "${tuto}-${stud}" ]; then                    
                    update_tutorial ${stud} ${repo}
                    proceed=true
                    break
                fi
            done
            
            if [ "$proceed" == true ]; then
                continue
            fi
            
            # for assignments, run the smoke test
            for assi in $assignments; do
                if [ "${repo}" == "${assi}-${stud}" ]; then
                    echo -e "${cyan}${repo} is an assignment${nc}"
                    cur_stud_assi=$(echo "$cur_stud_assigments" | jq '. | map(select(.name == "$repo")) | .[0]')
                    last_commit_date=$(echo "$cur_stud_assi" | jq '.last_commit_date')
                    repo_commit_date=$(curl -s https://api.github.com/repos/vvv-school/$repo/commits | jq '.[0] | .commit | .committer | .date')
                    if [ "${last_commit_date}" == "${repo_commit_date}" ]; then
                        echo -e "detected new activity on ${cyan}${repo}${nc} => start off testing"
                        result=$(smoke_test $repo https://github.com/${org}/${repo}.git)
                    fi
                    break
                fi
            done
        done
    done
done

