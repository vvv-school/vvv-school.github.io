#!/bin/bash

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.
#
# Dependencies (through apt-get):
# - jq
#
# The env variable GITHUB_TOKEN_VVV_SCHOOL shall contain a valid GitHub token
# (refer to instructions to find out more)
#

# color codes
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
cyan='\033[1;36m'
nc='\033[0m'

if [ $# -lt 4 ]; then
    echo "Usage: $0 <organization> <team> <abspath-to-gradebook> <abspath-to-build>"
    exit 1
fi

if [ -z "$GITHUB_TOKEN_VVV_SCHOOL" ]; then
    echo -e "${red}env variable GITHUB_TOKEN_VVV_SCHOOL is not set${data}${nc}\n"
    exit 2
fi

script=$(realpath $0)
abspathtoscript=$(dirname "${script}")

org=$1
team=$2
path=$3

cur_dir=$(pwd)
cd "$path"
website=$(git remote show origin | grep -i -m 1 url)
website=($website)
website=${website[2]}
cd ${cur_dir}

if [ ! -d $4 ]; then
    mkdir $4
fi
cd "$4"

data="$path"/data.json
README="$path"/README.md
gradebook_cur="$path"/gradebook.json
gradebook_new=gradebook-new.json
gradebook_tmp=gradebook-tmp.json

if [ ! -f "$data" ]; then
    echo -e "${red}Unable to find ${data}${nc}\n"
    exit 3
fi

# GitHub symbols
status_passed=":white_check_mark:"
status_failed=":x:"

# get students from $team
students=$("${abspathtoscript}"/get-members.rb $team)

tutorials=$(eval "cat $data | jq '.tutorials | .[] | .name' | sed 's/\\\"//g'")
assignments=$(eval "cat $data | jq '.assignments | .[] | .name' | sed 's/\\\"//g'")

# compute the student's score counting tutorials and assignments
function update_score {
    local stud=$1

    local stud_tutorials=$(eval "cat $gradebook_new | jq 'map(select(.username==\"$stud\")) | .[0].tutorials | .[] | .name' | sed 's/\\\"//g'")
    local stud_assignments=$(eval "cat $gradebook_new | jq 'map(select(.username==\"$stud\")) | .[0].assignments | .[] | .name' | sed 's/\\\"//g'")

    local jq_path
    local jq_path_status
    local jq_path_score
    local sc
    local score=0

    for tuto1 in $stud_tutorials; do
        for tuto2 in $tutorials; do
           if [ "${tuto1}" == "${tuto2}-${stud}" ]; then
              jq_path=$(eval "cat $gradebook_new | jq -c 'paths(.name?==\"$tuto1\")'")
              jq_path_score=$(echo "$jq_path" | jq -c '.+["score"]')
              sc=$(eval "cat $gradebook_new | jq 'getpath(${jq_path_score})'")
              let "score = $score + $sc"
              break
           fi
        done
    done

    for assi1 in $stud_assignments; do
        for assi2 in $assignments; do
           if [ "${assi1}" == "${assi2}-${stud}" ]; then
              jq_path=$(eval "cat $gradebook_new | jq -c 'paths(.name?==\"$assi1\")'")
              jq_path_status=$(echo "$jq_path" | jq -c '.+["status"]')
              local status=$(eval "cat $gradebook_new | jq 'getpath(${jq_path_status})' | sed 's/\\\"//g'")
              if [ "${status}" == "${status_passed}" ]; then
                 jq_path_score=$(echo "$jq_path" | jq -c '.+["score"]')
                 sc=$(eval "cat $gradebook_new | jq 'getpath(${jq_path_score})'")
                 let "score = $score + $sc"
              fi
              break
           fi
        done
    done

    echo -e "${green}${stud}${nc} has now score = ${cyan}${score}${nc}" > /dev/stderr
    jq_path=$(eval "cat $gradebook_new | jq -c 'paths(.username?==\"$stud\")'")
    jq_path=$(echo "$jq_path" | jq -c '.+["score"]')

    cp $gradebook_new $gradebook_tmp
    eval "cat $gradebook_tmp | jq 'setpath(${jq_path};${score})' > $gradebook_new"
    rm $gradebook_tmp
}

# push the new gradebook to GitHub
function publish_gradebook {
    local ret=0
    cp $gradebook_new $gradebook_cur
    cur_dir=$(pwd)

    cd "$path"
    git diff --quiet
    if [ $? -ne 0 ]; then
        ret=1
        echo -e "${green}Publishing the gradebook to $website${nc}\n" > /dev/stderr
        local keep_leading_lines=1
        cp $README $cur_dir/readme.tmp
        head -"${keep_leading_lines}" $cur_dir/readme.tmp > $README

        local num_students_1=$(eval "cat $gradebook_cur | jq 'length-1'")
        for i in `seq 0 $num_students_1`; do
            eval "cat $gradebook_cur | jq '.[$i]'" > $cur_dir/student_data.tmp
            local username=$(eval "cat $cur_dir/student_data.tmp | jq '.username' | sed 's/\\\"//g'")
            echo "" >> $README
            echo -e "### [**$username**](https://github.com/$username) grade\n" >> $README
            echo -e "| assignment | status | score |" >> $README
            echo -e "|    :--:    |  :--:  | :--:  |" >> $README
            local empty=true;

            eval "cat $cur_dir/student_data.tmp | jq '.tutorials'" > $cur_dir/tutorials_data.tmp
            local num_tutorials_1=$(eval "cat $cur_dir/tutorials_data.tmp | jq 'length-1'")
            for t in `seq 0 $num_tutorials_1`; do
                local name=$(eval "cat $cur_dir/tutorials_data.tmp | jq '.[$t] | .name' | sed 's/\\\"//g'")
                local status=$(eval "cat $cur_dir/tutorials_data.tmp | jq '.[$t] | .status' | sed 's/\\\"//g'")
                local score=$(eval "cat $cur_dir/tutorials_data.tmp | jq '.[$t] | .score'")
                if [ "$status" != "$status_passed" ]; then
                    score=0
                fi
                echo -e "| [$name](https://github.com/$org/$name) | $status | **$score** |" >> $README
                empty=false;
            done

            eval "cat $cur_dir/student_data.tmp | jq '.assignments'" > $cur_dir/assignments_data.tmp
            local num_assignments_1=$(eval "cat $cur_dir/assignments_data.tmp | jq 'length-1'")
            for a in `seq 0 $num_assignments_1`; do
                local name=$(eval "cat $cur_dir/assignments_data.tmp | jq '.[$a] | .name' | sed 's/\\\"//g'")
                local status=$(eval "cat $cur_dir/assignments_data.tmp | jq '.[$a] | .status' | sed 's/\\\"//g'")
                local score=$(eval "cat $cur_dir/assignments_data.tmp | jq '.[$a] | .score'")
                if [ "$status" != "$status_passed" ]; then
                    score=0
                fi
                echo -e "| [$name](https://github.com/$org/$name) | $status | **$score** |" >> $README
                empty=false;
            done

            if [ "${empty}" == "true" ]; then
                # remove the table
                cp $README $cur_dir/readme.tmp
                head -n -2 $cur_dir/readme.tmp > $README
            else
                echo "" >> $README
            fi

            local totscore=$(eval "cat $cur_dir/student_data.tmp | jq '.score'")
            local color="brightgreen"
            local style="flat-square"
            if [ $totscore -eq 0 ]; then
                color="orange"
            fi
            echo -e "![total score](https://img.shields.io/badge/total_score-${totscore}-${color}.svg?style=${style})\n" >> $README
            echo -e "---\n" >> $README
        done

        if [ -f $cur_dir/readme.tmp ]; then
            rm $cur_dir/readme.tmp
        fi
        if [ -f $cur_dir/student_data.tmp ]; then
            rm $cur_dir/student_data.tmp
        fi
        if [ -f $cur_dir/tutorials_data.tmp ]; then
            rm $cur_dir/tutorials_data.tmp
        fi
        if [ -f $cur_dir/assignments_data.tmp ]; then
            rm $cur_dir/assignments_data.tmp
        fi

        git add $gradebook_cur $README
        git commit --quiet -m "updated by automatic grading script"
        git push --quiet origin master
        if [ $? -ne 0 ]; then
            echo -e "${red}Problems detected while pushing to GitHub${nc}" > /dev/stderr
        fi
    fi

    cd $cur_dir
    return $ret
}

function smoke_test() {
    local repo=$1
    local url=$2
    local orig_repo=$3
    if [ -d $repo ]; then
        rm -Rf $repo
    fi

    local ret=252
    git clone --depth 1 -b master $url
    if [ $? -eq 0 ]; then
        if [ -d $repo/smoke-test ]; then
            if [ -f $repo/smoke-test/test-type ]; then
                # run the original helper script and test anyway,
                # not the one in $repo, to avoid any possible cheating ;)
                local orig_url=$(eval "cat $data | jq '.assignments | map(select(.name==\"$orig_repo\")) | .[0].url' | sed 's/\\\"//g'")

                if [ -d $orig_repo ]; then
                    rm -Rf $orig_repo
                fi
                git clone --depth 1 -b master $orig_url $orig_repo

                if [ -d smoke-test-tmp ]; then
                    rm -Rf smoke-test-tmp
                fi
                git clone --depth 1 -b master https://github.com/vvv-school/vvv-school.github.io.git ./smoke-test-tmp/helpers

                # we need absolute paths
                mkdir ./smoke-test-tmp/build
                local build_dir=$(pwd)/smoke-test-tmp/build
                local code_dir=$(pwd)/$repo
                local test_dir=$(pwd)/$orig_repo/smoke-test

                test_type=$(head -1 $repo/smoke-test/test-type)
                ./smoke-test-tmp/helpers/scripts/smoke-test-${test_type}.sh $build_dir $code_dir $test_dir
                ret=$?
            else
                echo -e "${red}test-type is missing${nc}" > /dev/stderr
            fi
        else
            echo -e "${red}${repo} does not contain smoke-test${nc}" > /dev/stderr
        fi
    else
        echo -e "${red}GitHub seems unreachable${nc}" > /dev/stderr
    fi

    return $ret
}

# update tutorial in the new gradebook
function update_tutorial {
    local stud=$1
    local tuto=$2
    local repo="${tuto}-${stud}"

    echo -e "${cyan}${repo} is a tutorial${nc} => given for granted ;)" > /dev/stderr

    # we assume it exists only one $repo in the gradebook
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

        local tutorial_score=$(eval "cat $data | jq '.tutorials | map(select(.name==\"$tuto\")) | .[0].score'")

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
    return $?
}

function update_assignment {
    local stud=$1
    local assi=$2
    local repo="${assi}-${stud}"

    echo -e "${cyan}${repo} is an assignment${nc}" > /dev/stderr

    local last_commit_date=$(eval "cat $gradebook_new | jq 'map(select(.username == \"$stud\")) | .[0].assignments | map(select(.name==\"$repo\")) | .[0].last_commit_date' | sed 's/\\\"//g'")
    local repo_commit_date=$("${abspathtoscript}"/get-commit-date.rb $org/$repo)

    if [ "${last_commit_date}" != "${repo_commit_date}" ] || [ -z "${repo_commit_date}" ]; then
        echo -e "${yellow}detected activity${nc} on ${cyan}${repo}${nc} => start off testing" > /dev/stderr

        local url=$(echo "${stud}-grade" | tr '[:upper:]' '[:lower:]')
        url="${website}#${url}"

        "${abspathtoscript}"/set-commit-status.rb $org/$repo pending $url

        local status=$status_failed
        local commit_status="error"

        smoke_test $repo https://github.com/${org}/${repo}.git $assi
        test_score=$?

        if [ $test_score -ge 0 ] && [ $test_score -le 100 ]; then
            status=$status_passed
            commit_status="success"
        elif [ $test_score -eq 255 ]; then
            commit_status="failure"
        fi

        local assignment_score=$(eval "cat $data | jq '.assignments | map(select(.name==\"$assi\")) | .[0].score'")
        if [ $test_score -ge 1 ] && [ $test_score -le 100 ]; then
            assignment_score=$test_score
        fi

        "${abspathtoscript}"/set-commit-status.rb $org/$repo $commit_status $url $assignment_score

        # we assume it exists only one $repo in the gradebook
        local jq_path=$(eval "cat $gradebook_new | jq -c 'paths(.name?==\"$repo\")'")
        if [ ! -z "$jq_path" ]; then
            local jq_path_status=$(echo "$jq_path" | jq -c '.+["status"]')
            local jq_path_date=$(echo "$jq_path" | jq -c '.+["last_commit_date"]')
            local jq_path_score=$(echo "$jq_path" | jq -c '.+["score"]')

            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'setpath(${jq_path_status};\"${status}\")' > $gradebook_new"

            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'setpath(${jq_path_date};\"${repo_commit_date}\")' > $gradebook_new"

            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'setpath(${jq_path_score};${assignment_score})' > $gradebook_new"
            rm $gradebook_tmp
        else
            local jq_path_student=$(eval "cat $gradebook_new | jq -c 'paths(.username?==\"$stud\")'")
            local jq_path_assignment=0
            if [ ! -z "$jq_path_student" ]; then
                jq_path_assignment=$(eval "cat $gradebook_new | jq '.[] | select(.username==\"$stud\") | .assignments | length'")
            else
                jq_path_student=$(eval "cat $gradebook_new | jq 'length'")
            fi

            echo "$jq_path_student" > $gradebook_tmp
            local jq_path_name=$(eval "cat $gradebook_tmp | jq -c '.+[\"assignments\",$jq_path_assignment,\"name\"]'")
            local jq_path_status=$(eval "cat $gradebook_tmp | jq -c '.+[\"assignments\",$jq_path_assignment,\"status\"]'")
            local jq_path_date=$(eval "cat $gradebook_tmp | jq -c '.+[\"assignments\",$jq_path_assignment,\"last_commit_date\"]'")
            local jq_path_score=$(eval "cat $gradebook_tmp | jq -c '.+[\"assignments\",$jq_path_assignment,\"score\"]'")

            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'setpath(${jq_path_name};\"${repo}\")' > $gradebook_new"

            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'setpath(${jq_path_status};\"${status}\")' > $gradebook_new"

            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'setpath(${jq_path_date};\"${repo_commit_date}\")' > $gradebook_new"

            cp $gradebook_new $gradebook_tmp
            eval "cat $gradebook_tmp | jq 'setpath(${jq_path_score};${assignment_score})' > $gradebook_new"
            rm $gradebook_tmp
        fi
    fi

    update_score ${stud}
    publish_gradebook
    return $?
}

# remove usernames not in $team
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
            echo -e "Removing ${red}${user}${nc} from gradebook; he's not in ${green}${team}${nc}" > /dev/stderr
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
            echo -e "Adding ${green}${stud}${nc} to gradebook" > /dev/stderr
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
            echo -e "Removing ${cyan}${tuto}${nc} from gradebook; it's not in ${cyan}${org}${nc}"  > /dev/stderr
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
    echo -e "\n${red}shutting down...${nc}\n" > /dev/stderr
    exit 0
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c SIGINT

webhook_file_name="/tmp/github-webhook-vvv-school"
webhook_requests="0"

do_loop=true
while true; do
    if [ "$do_loop" == true ]; then
                if [ -f $webhook_file_name ]; then
			do_loop=false
		fi

		if [ -f $gradebook_new ]; then
			rm $gradebook_new
		fi

		# generate new gradebook from old one, if exists
		if [ -f $gradebook_cur ]; then
			if [ -s $gradebook_cur ]; then
				cp $gradebook_cur $gradebook_new
			fi
		fi

		# otherwise produce an empy gradebook
		if [ ! -f $gradebook_new ]; then
			echo "[]" > $gradebook_new
		fi

		# retrieve names of all repositories in $org
		repositories=$("${abspathtoscript}"/get-repositories.rb $org)

		echo ""
		echo -e "${cyan}============================================================================${nc}"
		echo -e "Working out students of ${green}${team}${nc}:\n${green}${students}${nc}\n"
		echo -e "Against repositories in ${cyan}https://github.com/${org}:\n${blue}${repositories}${nc}\n"

		# remove from the gradebook users who are not students,
		# since they can be potentially in the original gradebook
		gc_usernames_no_students

		# add up missing students to the current gradebook
		add_missing_students

		# publish if a change has occurred
		publish_gradebook

		# for each student in the list
		for stud in $students; do
			echo -e "${cyan}==== Grading ${green}${stud}${nc}"

			# remove student's repositories that are not in $org
			gc_student_repositories $stud ${repositories[@]}

			# for each repository found in $org
			for repo in $repositories; do

				# for tutorials, simply give them for granted
				for tuto in $tutorials; do
					if [ "${repo}" == "${tuto}-${stud}" ]; then
						update_tutorial ${stud} ${tuto}
						if [ "$?" -eq 1 ]; then
							do_loop=true
						fi
						break
					fi
				done

				# for assignments, run the smoke test
				for assi in $assignments; do
					if [ "${repo}" == "${assi}-${stud}" ]; then
						update_assignment ${stud} ${assi}
						if [ "$?" -eq 1 ]; then
							do_loop=true
						fi
						break
					fi
				done
			done

			# newline
			echo ""
	    done
    else
            new_req=$(tail -1 "${webhook_file_name}")
            if [ "${new_req}" != "${webhook_requests}" ]; then
                        webhook_requests="${new_req}"
                        do_loop=true
            else
                        echo "."
                        sleep 10
            fi
    fi
done
