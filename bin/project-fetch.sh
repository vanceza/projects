project_fetch() {
    if [ $# -ne 1 ]; then; project_usage fetch; exit 1; fi
    PROJECT="$1"

    TARGET_DIR="${PROJECTS_HOME}/${PROJECT}"
    if [ ! -e "${TARGET_DIR}" ]
    then
        # The directory doesn't exist
        echo "Creating ${TARGET_DIR}" >/dev/stderr
    elif [ -L "${TARGET_DIR}" ]
    then
        TARGET_DIR="$(readlink -e "${TARGET_DIR}")" || {
            echo "${TARGET_DIR} is a dangling symbolic link" >/dev/stderr
            exit 1
        }
    fi

    if [ -d "${TARGET_DIR}" ]
    then
        # The directory exists...
        if [ -n "$(ls -A "${TARGET_DIR}")" ]
        then
            # ...and is nonempty
            # Check if it's a git repo
            [ -d .git ] || {
                echo "${TARGET_DIR} exists and is not a git repository" >/dev/stderr
                exit 1
            }
            # Check if it has the correct 
        else
            # ...and is empty
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
