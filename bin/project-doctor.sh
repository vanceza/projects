github_projects() {
    if is_command gh
    then
        gh repo --list | grep -v "forks" | grep -v "all repos" | tr -s "\n" | sed -e "s/.*\\///"
    else
        echo "Install gh (npm install -g gh) to check github projects" >/dev/stderr
    fi
}

deadtree_projects() {
    ssh deadtree bash 2>/dev/null <<BASH
        cd /git
        ls | sed -e 's/.git//' | sort
BASH
}

project_doctor() {
    OK=yes
    echo "Linting ${PROJECTS}" >/dev/stderr
    if project_lint >/dev/null
    then
        PROJECT_LIST=$(mktemp)
        project_list >"${PROJECT_LIST}"

        # Check the validity of every project
        echo "Checking validity of all projects" >/dev/stderr
        while read PROJECT
        do
            case $(project_status "${PROJECT}") in
            invalid)
                project_status -v "${PROJECT}" | tail -n+2
                unset OK
                ;;
            dirty)
                #echo "${PROJECT} is dirty"
                ;;
            esac
        done <"${PROJECT_LIST}"

        # Ping every remote
        echo "Pinging all remotes" >/dev/stderr
        xargs -n 1 -P 0 -I{} -- "$0" ping {} <${PROJECT_LIST} || unset OK

        # Find missing deadtree projects
        echo "Looking for missing deadtree projects" >/dev/stderr
        DEADTREE_LIST=$(mktemp)
        deadtree_projects | comm -2 -3 - "${PROJECT_LIST}" >"${DEADTREE_LIST}"
        while read MISSING
        do
            echo "${MISSING} is on deadtree but not on the local system" >/dev/stderr
            unset OK
        done <"${DEADTREE_LIST}"
        rm "${DEADTREE_LIST}"

        # Find missing github projects
        echo "Looking for missing github projects" >/dev/stderr
        GITHUB_LIST=$(mktemp)
        github_projects | comm -2 -3 - "${PROJECT_LIST}" >"${GITHUB_LIST}"
        while read MISSING
        do
            echo "${MISSING} is on github but not on the local system" >/dev/stderr
            unset OK
        done <"${GITHUB_LIST}"
        rm "${GITHUB_LIST}"

        rm "${PROJECT_LIST}"
    else
        unset OK
    fi

    if [ "$OK" ]
    then
        return 0
    else
        return 1
    fi
}

project_doctor_help() {
    cat <<EOF
Usage: project doctor
  Checks the health of the project system (various sanity checks)
EOF
}
