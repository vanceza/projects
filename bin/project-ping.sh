read_access() {
    git ls-remote "$1" >/dev/null 2>/dev/null
}

project_ping() {
    if [ $# -ne 1 ]
    then
        project_help ping
        exit 1
    fi
    PROJECT="$1"
    if find_project "${PROJECT}"
    then
        GIT_REMOTE="$(project_remote_for "${PROJECT}")"
        # Check read access
        if read_access "${GIT_REMOTE}"
        then
            :
        else
            echo "Don't have read access to: ${GIT_REMOTE}" >/dev/stderr
            exit 1
        fi

        case ${REMOTE} in
        github)
            # TODO: Check write access through API
            ;;
        burn)
            # TODO: Check write access by checking permissions with the correct user
            ;;
        *)
            echo "Don't know how to check remote: ${REMOTE}"
            exit 1
            ;;
        esac
    else
        echo "Project ${PROJECT} does not exist" >/dev/stderr
        exit 1
    fi
}

project_ping_help() {
    cat <<EOF
Usage: project ping
  Checks remote access to a project.
EOF
}
