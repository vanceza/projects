project_status() {
    unset VERBOSE PROJECT
    NARGS=0
    while [ $# -gt 0 ]
    do
        case "$1" in
        -v|--verbose)
            VERBOSE=YES
            ;;
        *)
            if [ -z "${PROJECT}" ]
            then
                PROJECT="$1"
            else
                project_help "status"
                exit 1
            fi
            NARGS=$((NARGS+1))
            ;;
        esac
        shift
    done
    if [ $NARGS -eq 0 ]
    then
        PROJECT="$(basename "$(pwd)")"
    fi
    if [ $NARGS -gt 1 ]
    then
        project_help "status"
        exit 1
    fi
    export VERBOSE
    TARGET_DIR="${PROJECTS_HOME}/${PROJECT}"

    # See if the archive directory exists
    ARCHIVE_DIR="${PROJECTS_ARCHIVE_DIR}/${PROJECT}"
    [ -e "${ARCHIVE_DIR}" ] && [ \! -d "${ARCHIVE_DIR}" ] && {
        echo "invalid"
        echo_verbose "${ARCHIVE_DIR} is not a directory"
        return 0
    }
    [ -e "${ARCHIVE_DIR}" ] || unset ARCHIVE_DIR

    # Check if the target directory doesn't exist
    if [ \! -e "${TARGET_DIR}" ]
    then
        if [ -n "$ARCHIVE_DIR" ]
        then
            echo "archived"
            return 0
        else
            echo "empty"
            echo_verbose "${TARGET_DIR} does not exist"
            return 0
        fi
    fi

    # Dereference any symbolic links
    TARGET_DIR="${PROJECTS_HOME}/${PROJECT}"
    if [ -L "${TARGET_DIR}" ]
    then
        NEW_TARGET_DIR="$(readlink -e "${TARGET_DIR}")" || {
            echo "invalid"
            echo_verbose "${TARGET_DIR} is a dangling symbolic link"
            return 0
        }
        echo_verbose "Dereferencing ${TARGET_DIR} to ${NEW_TARGET_DIR}"
        TARGET_DIR="${NEW_TARGET_DIR}"
    fi
    
    # The project location is a file, device file, etc
    if [ \! -d "${TARGET_DIR}" ]
    then
        echo "invalid"
        echo_verbose "${TARGET_DIR} is not a directory"
        return 0
    fi

    # The directory exists and is empty
    if [ -z "$(ls -A "${TARGET_DIR}")" ]
    then
        if [ -n "${ARCHIVE_DIR}" ]
        then
            echo "archived"
            return 0
        else
            echo "empty"
            echo_verbose "${TARGET_DIR} exists and is empty"
            return 0
        fi
    fi

    cd "${TARGET_DIR}"
    # Check if it's a git repo
    if [ \! -d .git ]
    then
        echo "invalid"
        echo_verbose "${TARGET_DIR} exists and is not a git repository"
        return 0
    elif git remote -v >/dev/null 2>&1
    then
        :
    else
        echo "invalid"
        echo_verbose "${TARGET_DIR} is not a valid git repository"
        return 0
    fi

    # Check if it has the correct remote
    EXPECTED_REMOTE="$(project_remote_for "${PROJECT}")"
    line="$(git remote -v | grep origin | grep "fetch" | head -n1)"
    [ -n "${line}" ] || {
        echo "invalid"
        echo_verbose "${TARGET_DIR} exists but has no 'origin' remote"
        return 0
    }
    FS_REMOTE="$(echo "$line" | sed -e 's/ (fetch)//' -e 's/origin\t//')"
    if [ "${FS_REMOTE}" != "${EXPECTED_REMOTE}" ]
    then
        if [ -z "${EXPECTED_REMOTE}" ]
        then
            echo "invalid"
            echo_verbose "${TARGET_DIR} is a git repository but not a listed project"
            echo_verbose "Its 'origin' remote is pointed at ${FS_REMOTE}"
            return 0
        else
            echo "invalid"
            echo_verbose "${TARGET_DIR} exists but its 'origin' remote is pointed at ${FS_REMOTE}"
            return 0
        fi
    fi
    
    # The git repo DOES exist with the correct remote at this point.
    # Check for an additional archived version
    if [ -n "${ARCHIVE_DIR}" ]
    then
        echo "invalid"
        echo_verbose "${PROJECT} has both a checked out and an archived version"
        return 0
    fi

    # Check for uncommitted changes
    if [ "$(git diff --shortstat 2> /dev/null | tail -n1)" != "" ]
    then
        echo "dirty"
        echo_verbose "${PROJECT} has uncommitted changes"
        return 0
    fi

    # Check for unpushed changes (TODO: Only checks current branch)
    if git log origin/master..HEAD | is_empty
    then
        echo "clean"
        return 0
    else
        echo "dirty"
        echo_verbose "${PROJECT} has all changes committed, but some are not pushed upstream"
        return 0
    fi
}

project_status_help() {
    cat <<EOF
Usage: project status [-v] [PROJECT]
  Returns a short status string with the state of the project

  One of:
    clean         Project is checked out with no unsaved changes
    dirty         Project is checked out with unsaved changes
    archived      Project is not checked out but is archived
    empty         Project is neither checked out nor archived
    invalid       Not a valid project

  Options:
    -v            Print additional status information
EOF
}
