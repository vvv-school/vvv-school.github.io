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
README=$path/README.md
gradebook_cur=$path/gradebook.json
gradebook_new=gradebook-new.json
gradebook_tmp=gradebook-tmp.json

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

# GitHub token for authorized access (required for rate limit)
token_header="-H \"Authorization: token $GIT_TOKEN_ORG_READ\""

# get students from $team
team_id=$(eval "curl -s $token_header -G https://api.github.com/orgs/vvv-school/teams | jq 'map(select(.name==\"$team\")) | .[0] | .id'")
students=$(eval "curl -s $token_header -G https://api.github.com/teams/$team_id/members | jq '.[] | .login' | sed 's/\"//g'")

tutorials=$(eval "cat $data | jq '.tutorials | .[] | .name' | sed 's/\\\"//g'")
assignments=$(eval "cat $data | jq '.assignments | .[] | .name' | sed 's/\\\"//g'")

# compute the student's score counting tutorials and assignments
function update_score {
    local stud=$1
    
    local stud_tutorials=$(eval "cat $gradebook_new | jq 'map(select(.username==\"$stud\")) | .[0] | .tutorials | .[] | .name' | sed 's/\\\"//g'")
    local stud_assignments=$(eval "cat $gradebook_new | jq 'map(select(.username==\"$stud\")) | .[0] | .assignments | .[] | .name' | sed 's/\\\"//g'")

    local score=0
    for tuto1 in $stud_tutorials; do
        for tuto2 in $tutorials; do
           if [ "${tuto1}" == "${tuto2}-${stud}" ]; then
              local tmp=$(eval "cat $data | jq '.tutorials | map(select(.name==\"$tuto2\")) | .[0] | .score'")
              let "score = $score + $tmp"
              break
           fi 
        done
    done
    
    for assi1 in $stud_assignments; do
        for assi2 in $assignments; do
           if [ "${assi1}" == "${assi2}-${stud}" ]; then
              local item=$(eval "cat $data | jq '.assignments | map(select(.name==\"$assi2\")) | .[0]'")
              local tmp=$(echo "$item" | jq '.status')
              if [ "${tmp}" == "${status_passed}" ]; then
                 tmp=$(echo "$item" | jq '.score')
                 let "score = $score + $tmp"
              fi
              break
           fi 
        done
    done
    
    echo -e "${green}${stud}${nc} has now score = ${cyan}${score}${nc}" > /dev/stderr
    local jq_path=$(eval "cat $gradebook_new | jq -c 'paths(.username?==\"$stud\")'") 
    jq_path=$(echo "$jq_path" | jq -c '.+["score"]')
    
    cp $gradebook_new $gradebook_tmp
    eval "cat $gradebook_tmp | jq 'setpath(${jq_path};${score})' > $gradebook_new"
    rm $gradebook_tmp
}

# push the new gradebook to GitHub
function publish_gradebook {
    cp $gradebook_new $gradebook_cur

    git diff --quiet
    if [ $? -ne 0 ]; then
        echo -e "${green}Publishing the gradebook${nc}\n" > /dev/stderr
        local keep_leading_lines=1
        cp $README readme.tmp
        head -"${keep_leading_lines}" readme.tmp > $README
        
        local num_students_1=$(eval "cat $gradebook_cur | jq 'length-1'")
        for i in `seq 0 $num_students_1`; do
            eval "cat $gradebook_cur | jq '.[$i]'" > student_data.tmp
            local username=$(eval "cat student_data.tmp | jq '.username' | sed 's/\\\"//g'")
            local totscore=$(eval "cat student_data.tmp | jq '.score'")
            echo "" >> $README
            echo -e "### [**$username**](https://github.com/$username) has score = **$totscore**\n" >> $README
            echo -e "| assignment | status | score |" >> $README
            echo -e "|    :--:    |  :--:  | :--:  |" >> $README
            local empty=true;
            
            eval "cat student_data.tmp | jq '.tutorials'" > tutorials_data.tmp
            local num_tutorials_1=$(eval "cat tutorials_data.tmp | jq 'length-1'")
            for t in `seq 0 $num_tutorials_1`; do
                local name=$(eval "cat tutorials_data.tmp | jq '.[$t] | .name' | sed 's/\\\"//g'")
                local status=$(eval "cat tutorials_data.tmp | jq '.[$t] | .status' | sed 's/\\\"//g'")
                local score=$(eval "cat tutorials_data.tmp | jq '.[$t] | .score'")
                echo -e "| [$name](https://github.com/$org/$name) | $status | $score |" >> $README
                empty=false;
            done
        
            eval "cat student_data.tmp | jq '.assignments'" > assignments_data.tmp
            local num_assignments_1=$(eval "cat assignments_data.tmp | jq 'length-1'")
            for a in `seq 0 $num_assignments_1`; do
                local name=$(eval "cat assignments_data.tmp | jq '.[$a] | .name' | sed 's/\\\"//g'")
                local status=$(eval "cat assignments_data.tmp | jq '.[$a] | .status' | sed 's/\\\"//g'")
                local score=$(eval "cat assignments_data.tmp | jq '.[$a] | .score'")
                echo -e "| [$name](https://github.com/$org/$name) | $status | $score |" >> $README
                empty=false;
            done
            
            if [ "${empty}" == "true" ]; then
                # remove the table
                cp $README readme.tmp
                head -n -2 readme.tmp > $README                
            fi
            
            # newline
            echo "" >> $README
        done
        
        if [ -f readme.tmp ]; then
            rm readme.tmp
        fi
        if [ -f student_data.tmp ]; then
            rm student_data.tmp
        fi
        if [ -f tutorials_data.tmp ]; then
            rm tutorials_data.tmp
        fi
        if [ -f assignments_data.tmp ]; then
            rm assignments_data.tmp
        fi

        git add $gradebook_cur $README
        git commit --quiet -m "updated by automatic grading script"
        git push --quiet origin master
        if [ $? -ne 0 ]; then
            echo -e "${red}Problems detected while pushing to GitHub${nc}" > /dev/stderr
        fi
    fi
}

# update tutorial in the new gradebook
function update_tutorial {
    local stud=$1
    local tuto=$2
    local repo="${tuto}-${stud}"
    
    echo -e "${cyan}${repo} is a tutorial${nc} => given for granted ;)" > /dev/stderr

    local jq_path=$(eval "cat $gradebook_new | jq -c 'paths(.name?==\"$repo\")'")
    if [ ! -z "$jq_path" ]; then
        jq_path=$(echo "$jq_path" | jq -c '.+["status"]')
        
        cp $gradebook_new $gradebook_tmp
        eval "cat $gradebook_tmp | jq 'setpath(${jq_path};\"${status_passed}\")' > $gradebook_new"
        rm $gradebook_tmp
    else
        local jq_path_student=$(eval "cat $gradebook_new | jq -c 'paths(.username?==\"$stud\")'")
        local jq_path_tutorial=0
        if [ ! -z "$jq_path_student" ]; then
            jq_path_tutorial=$(eval "cat $gradebook_new | jq '.[] | select(.username==\"$stud\") | .tutorials | length'")
        else
            jq_path_student=$(eval "cat $gradebook_new | jq 'length'")
        fi

        local tutorial_score=$(eval "cat $data | jq '.tutorials | map(select(.name==\"$tuto\")) | .[0] | .score'")

        echo "$jq_path_student" > $gradebook_tmp        
        local jq_path_name=$(eval "cat $gradebook_tmp | jq -c '.+[\"tutorials\",$jq_path_tutorial,\"name\"]'")
        local jq_path_status=$(eval "cat $gradebook_tmp | jq -c '.+[\"tutorials\",$jq_path_tutorial,\"status\"]'")
        local jq_path_score=$(eval "cat $gradebook_tmp | jq -c '.+[\"tutorials\",$jq_path_tutorial,\"score\"]'")
                
        cp $gradebook_new $gradebook_tmp
        eval "cat $gradebook_tmp | jq 'setpath(${jq_path_name};\"${repo}\")' > $gradebook_new"
        
        cp $gradebook_new $gradebook_tmp
        eval "cat $gradebook_tmp | jq 'setpath(${jq_path_status};\"${status_passed}\")' > $gradebook_new"
        
        cp $gradebook_new $gradebook_tmp
        eval "cat $gradebook_tmp | jq 'setpath(${jq_path_score};${tutorial_score})' > $gradebook_new"
        rm $gradebook_tmp
    fi

    update_score ${stud}
    publish_gradebook
}

# function update_assignment {
# }

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

# remove usernames not in ${team}
function gc_usernames_no_students {
    local usernames=$(eval "cat $gradebook_new | jq 'map(.username) | .[]' | sed 's/\\\"//g'")
    local newline=false
    
    for user in $usernames; do
        local isin=false
        for stud in $students; do
            if [ "${user}" == "${stud}" ]; then
                isin=true
                break;
            fi
        done
        
        if [ "${isin}" == "false" ]; then
            echo "Removing ${user} from gradebook; he's not in ${team}" > /dev/stderr
            newline=true
            
            local jq_path_user=$(eval "cat $gradebook_new | jq -c 'paths(.username?==\"$user\") | .[0]'")
            
            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'del(.[${jq_path_user}])' > $gradebook_new"
            rm $gradebook_tmp            
        fi
    done
    
    if [ "$newline" == "true" ]; then
        echo ""
    fi
}

# add missing students as empty items
function add_missing_students {  
    local newline=false
    
    for stud in $students; do
        local isin=$(eval "cat $gradebook_new | jq 'map(select(.username==\"${stud}\")) | .[0] | .username'")
        if [ "$isin" == "null" ]; then
            echo "Adding ${stud} to gradebook" > /dev/stderr
            newline=true
            
            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq '.+ [{\"username\": \"${stud}\", \"tutorials\": [], \"assignments\": [], score: 0}]' > $gradebook_new"
            rm $gradebook_tmp
        fi
    done
    
    if [ "$newline" == "true" ]; then
        echo ""
    fi
}

# remove student's unavailable repositories
function gc_student_repositories {
    local stud=$1
    shift
    local repositories=${@}

    local jq_path_stud=$(eval "cat $gradebook_new | jq -c 'paths(.username?==\"$stud\") | .[0]'")
    
    local stud_tutorials=$(eval "cat $gradebook_new | jq 'map(select(.username==\"$stud\")) | .[0] | .tutorials'")
    local stud_tutorials_name=$(echo "$stud_tutorials" | jq '.[] | .name' | sed 's/\"//g')
    for tuto in $stud_tutorials_name; do        
        local isin=false
        for repo in $repositories; do
            if [ "${tuto}" == "${repo}" ]; then
                isin=true
                break
            fi
        done
        
        if [ "${isin}" == "false" ]; then
            echo "Removing ${tuto} from gradebook; it's not in ${org}"  > /dev/stderr
            echo "$stud_tutorials" > $gradebook_tmp
            local jq_path_tuto=$(eval "cat $gradebook_tmp | jq -c 'paths(.name?==\"$tuto\") | .[0]'")
                        
            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'del(.[${jq_path_stud}].tutorials[${jq_path_tuto}])' > $gradebook_new"
            rm $gradebook_tmp
            
            # recompute data
            local stud_tutorials=$(eval "cat $gradebook_new | jq 'map(select(.username==\"$stud\")) | .[0] | .tutorials'")
        fi
    done
    
    local stud_assignments=$(eval "cat $gradebook_new | jq 'map(select(.username==\"$stud\")) | .[0] | .assignments'")
    local stud_assignments_name=$(echo "$stud_assignments" | jq '.[] | .name' | sed 's/\"//g')
    for assi in $stud_assignments_name; do
        local isin=false
        for repo in $repositories; do
            if [ "${assi}" == "${repo}" ]; then
                isin=true
                break
            fi
        done

        if [ "${isin}" == "false" ]; then
            echo "Removing ${assi} from gradebook; it's not in ${org}" > /dev/stderr
            echo "$stud_assignments" > $gradebook_tmp
            local jq_path_assi=$(eval "cat $gradebook_tmp | jq -c 'paths(.name?==\"$assi\") | .[0]'")

            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'del(.[${jq_path_stud}].assignments[${jq_path_assi}])' > $gradebook_new"
            rm $gradebook_tmp
            
            # recompute data
            local stud_assignments=$(eval "cat $gradebook_new | jq 'map(select(.username==\"$stud\")) | .[0] | .assignments'")
        fi
    done
    
    update_score ${stud}
    publish_gradebook
}

# try to shut down gracefully
function ctrl_c() {
    echo -e "\n${red}Trapped CTRL-C, shutting down...${nc}\n" > /dev/stderr
    exit 0
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c SIGINT

while true; do
    # generate new gradebook from old one, if exists
    if [ -f $gradebook_new ]; then
        rm $gradebook_new
    fi
    if [ -f $gradebook_cur ]; then
        cp $gradebook_cur $gradebook_new
    else
        echo "[]" > $gradebook_new
    fi
    
    repositories=$(eval "curl -s $token_header -G https://api.github.com/orgs/$org/repos?type=public | jq '.[] | .name' | sed 's/\\\"//g'")
        
    echo ""
    echo -e "Working out the students:\n${green}${students}${nc}\n"
    echo -e "Against repositories in ${cyan}https://github.com/${org}:\n${blue}${repositories}${nc}\n"
    
    gc_usernames_no_students
    add_missing_students

    publish_gradebook

    # for each student in the list
    for stud in $students; do
        echo -e "${cyan}==== Grading ${green}${stud}${nc}"
        
        # remove student's unavailable repositories
        gc_student_repositories $stud ${repositories[@]}
        
        cur_stud_assignments=$(eval "cat $gradebook_new | jq '. | map(select(.username == \"$stud\")) | .[0] | .assignments'")
            
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
                    cur_stud_assi=$(echo "$cur_stud_assignments" | jq '. | map(select(.name=="$repo")) | .[0]')
                    last_commit_date=$(echo "$cur_stud_assi" | jq '.last_commit_date')
                    repo_commit_date=$(eval "curl -s $token_header -G https://api.github.com/repos/vvv-school/$repo/commits | jq '.[0] | .commit | .committer | .date'")
                    if [ "${last_commit_date}" == "${repo_commit_date}" ]; then
                        echo -e "detected new activity on ${cyan}${repo}${nc} => start off testing"
                        result=$(smoke_test $repo https://github.com/${org}/${repo}.git)
                    fi
                    break
                fi
            done
        done
        
        # newline
        echo ""
    done
done
