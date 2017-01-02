#!/bin/bash

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.

# Dependencies (through apt-get):
# - curl
# - jq

if [ $# -lt 4 ]; then
    echo "Usage: $0 <organization> <team> <abspath-to-gradebook> <abspath-to-build>"
    exit 1
fi

if [ -z "$GIT_TOKEN_ORG_READ" ]; then
    echo -e "${red}env variable GIT_TOKEN_ORG_READ is not set${data}${nc}\n"
    exit 2
fi

org=$1
team=$2
path=$3

if [ ! -d "$4" ]; then
    mkdir $4
fi
cd "$4"

data=$path/data.json
cur_gradebook=$path/gradebook.json
new_gradebook=new-gradebook.json

if [ ! -f "$data" ]; then
    echo -e "${red}Unable to find ${data}${nc}\n"
    exit 3
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

# get students from $team
token_header="-H \"Authorization: token $GIT_TOKEN_ORG_READ\""

query="curl -s $token_header -G https://api.github.com/orgs/vvv-school/teams | jq 'map(select(.name==\"$team\")) | .[0] | .id'"
team_id=$(eval $query)
query="curl -s $token_header -G https://api.github.com/teams/$team_id/members | jq '.[] | .login' | sed 's/\"//g'"
students=$(eval $query)

tutorials=$(cat $data | jq '.tutorials | .[] | .name' | sed 's/\"//g')
assignments=$(cat $data | jq '.assignments | .[] | .name' | sed 's/\"//g')

# compute the student's score counting tutorials and assignments
function update_score {
    local stud=$1
    
    local stud_tutorials=$(cat $new_gradebook | jq 'map(select(.username=="$stud")) | .[0] | .tutorials | .[] | .name' | sed 's/\"//g')
    local stud_assignments=$(cat $new_gradebook | jq 'map(select(.username=="$stud")) | .[0] | .assignments | .[] | .name' | sed 's/\"//g')
    
    local score=0
    for tuto1 in $stud_tutorials; do
        for tuto2 in $tutorials; do
           if [ "${tuto1}" == "${tuto2}-${stud}" ]; then              
              let "score = $score + $(cat $data | jq '.tutorials | map(select(.name=="$tuto2")) | .[0] | .score')"
              break
           fi 
        done
    done
    
    for assi1 in $stud_assignments; do
        for assi2 in $assignments; do
           if [ "${assi1}" == "${assi2}-${stud}" ]; then              
              let "score = $score + $(cat $data | jq '.assignments | map(select(.name=="$assi2")) | .[0] | .score')"
              break
           fi 
        done
    done
    
    echo -e "New score of ${green}${stud}${nc} is ${cyan}${score}${nc}" > /dev/stderr
    local jq_path_student=$(cat $new_gradebook | jq 'paths(.username?=="$stud")')    
    cat $new_gradebook | jq 'setpath([$jq_path_student,"score"];$score)' > $new_gradebook
}

# push the new gradebook to GitHub
function publish_gradebook {
    cp $new_gradebook $cur_gradebook
    local cur_dir=$(pwd)
    
    cd $path
    git diff --exit-code
    if [ $? -ne 0 ]; then
        local keep_leading_lines=1
        head "-${keep_leading_lines}" README.md > README.md
        
        local num_students_1=$(cat gradebook.json | jq 'length-1')
        for i in `seq 0 $num_students_1`; do
            local student_data=$(cat gradebook.json | jq '.[$i]')
            local username=$(cat ${student_data} | jq '.username')
            local totscore=$(cat ${student_data} | jq '.score')
            print "[**$username**](https://github.com/$username) total score = **$totscore**\n\n" >> README.md
            print "| repository | status | score |" >> README.md
            print "|    :--:    |  :--:  | :--:  |" >> README.md
            
            local tutorials_data=$(cat ${student_data} | jq '.tutorials')
            local num_tutorials_1=$(cat ${tutorials_data} | jq 'length-1')
            for t in `seq 0 $num_tutorials_1`; do
                local name=$(cat ${tutorials_data} jq '.[$t] | .name')
                local status=$(cat ${tutorials_data} | jq '.[$t] | .status')
                local score=$(cat ${tutorials_data} | jq '.[$t] | .score')
                print "| $name | $status | $score |\n" >> README.md
            done
        
            local assignments_data=$(cat ${student_data} | jq '.assignments')
            local num_assignments_1=$(cat ${assignments_data} | jq 'length-1')
            for a in `seq 0 $num_assignments_1`; do
                local name=$(cat ${assignments_data} jq '.[$a] | .name')
                local status=$(cat ${assignments_data} | jq '.[$a] | .status')
                local score=$(cat ${assignments_data} | jq '.[$a] | .score')
                print "| $name | $status | $score |\n" >> README.md
            done
        done
                    
        git add gradebook.json README.md
        git commit -m "updated by automatic grading script"
        git push origin master
        if [ $? -ne 0 ]; then
            echo -e "${red}Problems detected while pushing to GitHub${nc}" > /dev/stderr
        fi        
    fi
    
    cd $cur_dir
}

# update tutorial in the new gradebook
function update_tutorial {
    local stud=$1
    local tuto=$2
    local repo="${tuto}-${stud}"
    
    echo -e "${cyan}${repo} is a tutorial${nc} => given for granted ;)" > /dev/stderr
    
    if [ -f $new_gradebook ]; then
        rm $new_gradebook
    fi

    local jq_path=$(cat $cur_gradebook | jq 'paths(.name?=="$repo")')
    if [ ! -z "$jq_path" ]; then
        cat $cur_gradebook | jq 'setpath([$jq_path,"status"];$status_passed)' > $new_gradebook
    else        
        local jq_path_student=$(cat $cur_gradebook | jq 'paths(.username?=="$stud")')
        local jq_path_tutorial=0
        if [ ! -z "$jq_path_student" ]; then
            jq_path_tutorial=$(cat $cur_gradebook | jq '.[] | select(.username=="$stud") | .tutorials | length+1')
        else
            jq_path_student=$(cat $cur_gradebook | jq 'length+1')            
        fi
        
        local tutorial_score=$(cat $data | jq '.tutorials | map(select(.name=="$tuto")) | .[0] | .score')
        cat $cur_gradebook | jq 'setpath([$jq_path_student,"tutorials",$jq_path_tutorial,"name"];$repo) |\
                                 setpath([$jq_path_student,"tutorials",$jq_path_tutorial,"status"];$status_pased) |\
                                 setpath([$jq_path_student,"tutorials",$jq_path_tutorial,"score"];$tutorial_score)' > $new_gradebook
    fi
    
    update_score ${stud}
    publish_gradebook
}

function smoke_test()
{
    local repo=$1
    local url=$2
    if [ -d "$repo" ]; then
        rm $repo -rf
    fi
 
    local ret="error"
    git clone $url
    if [ $? -eq 0 ]; then        
        if [ -d "$repo/smoke-test" ]; then
            cd $repo/smoke-test
            ./test.sh
            ret=$?
        else
            echo -e "${red}${repo} does not contain smoke-test${nc}" > /dev/stderr
        fi
    else
        echo -e "${red}GitHub seems unreachable${nc}" > /dev/stderr
    fi

    echo $ret
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
    echo -e "Against repositories in ${cyan}https://github.com/${org}:\n${blue}${repositories}${nc}\n"

    # for each student in the list
    for stud in $students; do
        echo -e "${cyan}Grading ${green}${stud}${nc}"
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
                    update_tutorial ${stud} ${tuto}
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

