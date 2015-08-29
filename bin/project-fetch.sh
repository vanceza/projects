project_fetch() {
    if [ $# -ne 1 ]; then project_usage fetch; exit 1; fi
    PROJECT="$1"
    shift 1

    TARGET_DIR="${PROJECTS_HOME}/${PROJECT}"
    if [ -L "${TARGET_DIR}" ]
    then
        NEW_TARGET_DIR="$(readlink -e "${TARGET_DIR}")" || {
            echo "${TARGET_DIR} is a dangling symbolic link" >/dev/stderr
            exit 1
        }
        TARGET_DIR="${NEW_TARGET_DIR}"
    elif [ ! -e "${TARGET_DIR}" ]
    then
        # The directory doesn't exist
        echo "Creating ${TARGET_DIR}" >/dev/stderr
        mkdir "${TARGET_DIR}" || {
            echo "Cannot make directory ${TARGET_DIR}, aborting."
            exit 1
        }
    fi

    if [ -d "${TARGET_DIR}" ]
    then
        # The directory exists...
        if [ -n "$(ls -A "${TARGET_DIR}")" ]
        then
            # ...and is nonempty
            cd "${TARGET_DIR}"
            # Check if it's a git repo
            [ -d .git ] || {
                echo "${TARGET_DIR} exists and is not a git repository" >/dev/stderr
                exit 1
            }
            # Check if it has the correct remote
            git remote -v | grep origin | grep "fetch" | {
                read line || {
                    echo "${TARGET_DIR} exists but has no 'origin' remote" >/dev/stderr
                    exit 1
                }
                ACTUAL_REMOTE="$(echo "$line" | sed -e 's/ (fetch)//' -e 's/origin\t//')"
                EXPECTED_REMOTE="$(project_remote_for "${PROJECT}")"
                if [ "${ACTUAL_REMOTE}" = "${EXPECTED_REMOTE}" ]
                then
                    echo "${TARGET_DIR} is already checked out"
                    exit 0
                else 
                    echo "${TARGET_DIR} exists but its 'origin' remote is pointed at ${ACTUAL_REMOTE}"
                    exit 1
                fi
            }
        else
            # ...and is empty
            # Do an actual fetch
            cd "${TARGET_DIR}"
            REMOTE="$(project_remote_for "${PROJECT}")"
            git clone "${REMOTE}" .
        fi
    else
        # Directory does not exist
        echo "${TARGET_DIR} is not a directory" >/dev/stderr
        exit 1
    fi
}

project_fetch_help() {
    cat <<EOF
Usage: project fetch PROJECT
  Gets a local copy of the git repository. Does not update the repository if it exists.
EOF
}
