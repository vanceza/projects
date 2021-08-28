github_projects() {
    if is_command gh
    then
        gh repo list | grep -v "fork" | awk '{print $1}' | cut -f2 -d'/' | sort | grep -v "^za3k.com"
    else
        echo "Install gh (npm install -g gh) to check github projects" >/dev/stderr
    fi
}

germinate_projects() {
    ssh germinate bash 2>/dev/null <<BASH
        cd /data/git
        ls | sed -e 's/.git//' | sort | grep -v books-checked-out
BASH
}

project_doctor() {
    OK=yes
    unset FAST
    while [ $# -ge 1 ]; do
        case "$1" in
            -f|--fast)
              FAST=yes
              ;;
            *)
              ;;
        esac
        shift
    done
    STATUS=0
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
                echo "  '${PROJECT}' invalid" >&2
                [[ -z "$OK" && "$FAST" == "yes" ]] && exit 1
                ;;
            dirty)
                #echo "${PROJECT} is dirty"
                echo "  '${PROJECT}' dirty" >&2
                ;;
            *)
                #echo "${PROJECT} ok" >&2
                ;;
            esac
        done <"${PROJECT_LIST}"
        [[ -z "$OK" && "$FAST" == "yes" ]] && exit 1

        # Ping every remote
        echo "Pinging all remotes (note: sometimes ssh transiently fails)" >/dev/stderr
        xargs -n 1 -P 0 -- "$0" ping <${PROJECT_LIST} || unset OK
        [[ -z "$OK" && "$FAST" == "yes" ]] && exit 1

        # Find missing germinate projects
        echo "Looking for missing germinate projects" >/dev/stderr
        GERMINATE_LIST=$(mktemp)
        germinate_projects | sort | comm -2 -3 - "${PROJECT_LIST}" >"${GERMINATE_LIST}"
        while read MISSING
        do
            echo "${MISSING} is on germinate but not on the local system" >/dev/stderr
            unset OK
            [[ -z "$OK" && "$FAST" == "yes" ]] && exit 1
        done <"${GERMINATE_LIST}"
        rm "${GERMINATE_LIST}"

        # Find missing github projects
        echo "Looking for missing github projects" >/dev/stderr
        GITHUB_LIST=$(mktemp)
        github_projects | comm -2 -3 - "${PROJECT_LIST}" >"${GITHUB_LIST}"
        while read MISSING
        do
            echo "${MISSING} is on github but not on the local system" >/dev/stderr
            unset OK
            [[ -z "$OK" && "$FAST" == "yes" ]] && exit 1
        done <"${GITHUB_LIST}"
        rm "${GITHUB_LIST}"
        [[ -z "$OK" && "$FAST" == "yes" ]] && exit 1

        rm "${PROJECT_LIST}"
    else
        unset OK
        [[ -z "$OK" && "$FAST" == "yes" ]] && exit 1
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
Usage: project doctor [-f]
  Checks the health of the project system (various sanity checks)

  -f, --fast
    exit on the first failure
EOF
}
