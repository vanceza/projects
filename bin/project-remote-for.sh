project_remote_for() {
    if [ $# -ne 1 ]
    then
        project_help "remote-for"
        exit 1
    fi
    PROJECT="$1"
    if find_project "${PROJECT}"
    then
        case ${REMOTE} in
        github)
            echo "git@github.com:${USER}/${PROJECT}.git"
            ;;
        deadtree)
            if [ "${USER}" = "$(whoami)" ]
            then
                echo "deadtree:/git/${PROJECT}.git"
            else
                echo "${USER}@deadtree:/git/${PROJECT}.git"
            fi
            ;;
        *)
            echo "Invalid remote: ${REMOTE}" >/dev/stderr
            exit 1
            ;;
        esac
    fi
}

project_remote_for_help() {
    cat <<EOF
Usage: project remote-for PROJECT
  Print the git remote
EOF
}
