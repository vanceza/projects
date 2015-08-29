project_remote_for() {
    if [ $# -ne 1 ]
    then
        project_help "remote-for"
        exit 1
    fi
    PROJECT="$1"
    cat "${PROJECTS}" | while read LINE
    do
        line_project="$(echo "${LINE}" | awk '{ print $3 }')"
        if [ "${line_project}" = "${PROJECT}" ]
        then
            REMOTE="$(echo "${LINE}" | awk '{ print $1 }')"
            USER="$(echo "${LINE}" | awk '{ print $2 }')"
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
    done
}

project_remote_for_help() {
    cat <<EOF
Usage: project remote-for PROJECT
  Print the git remote
EOF
}
