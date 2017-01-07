valid_project_name() {
    VALID_PROJECT_CHARACTERS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-"
    ORIG_NAME="$1"
    FILTERED_NAME="$(echo "$1" | tr -cd "${VALID_PROJECT_CHARACTERS}")"
    [ "${ORIG_NAME}" = "${FILTERED_NAME}" ]
}

project_create() {
    unset DESCRIPTION REMOTE PROJECT REMOTE_MANUAL
    NARGS=0
    while [ $# -gt 0 ]
    do
        key="$1"
        shift
        case "$key" in
        -n|--name|--project)
            PROJECT="$1"
            shift
            ;;
        -r|--remote)
            REMOTE="$1"
            shift
            ;;
        -d|--description)
            DESCRIPTION="$1"
            shift
            ;;
        *)
            NARGS=$((NARGS+1))
            case ${NARGS} in
            1)
                REMOTE="${key}"
                ;;
            2)
                PROJECT="${key}"
                ;;
            esac
            ;;
        esac
    done
    if [ ${NARGS} -gt 2 ]
    then
        project_help create
        exit 1
    fi

    # Make sure the current directory is a git repo with no origin remote
    if [ \! -d .git ]
    then
        echo "Can only create a project for an existing git repository. Please make one before running this command." >/dev/stderr
        return 1
    fi
    if git remote -v >/dev/null 2>/dev/null
    then
        if git remote -v | grep origin >/dev/null 2>/dev/null
        then
            echo "This git repository already has an 'origin' remote. You must add it manually" >/dev/stderr
            return 1
        fi
    else
        echo "Git commands are failing. Fix the state of the current folder." >/dev/stderr
        return 1
    fi

    # Get the remote and make sure it is valid
    if [ -z "${REMOTE}" ]
    then
        REMOTE=burn
        if [ -t 0 ]
        then
            # Prompt
            echo -n "Remote [burn github] (${REMOTE}): "
            read PROMPT_REMOTE
            [ -z "${PROMPT_REMOTE}" ] || REMOTE="${PROMPT_REMOTE}"
        fi
    else
        REMOTE_MANUAL=YES
    fi
    case "${REMOTE}" in
    github)
        which gh >/dev/null 2>/dev/null || {
            echo "gh command is required to make a github repo (npm install -g gh)" >/dev/null
            return 1
        }
        ;;
    burn)
        ;;
    *)
        echo "Remote is not valid: ${REMOTE}" >/dev/stderr
        return 1
        ;;
    esac

    # Get the project name and make sure it is valid
    if [ -z "${PROJECT}" ]
    then
        PROJECT="$(basename "$(pwd)")" # Current directory name
        if [ -t 0 ]
        then
            # Prompt
            echo -n "Project (${PROJECT}): "
            read PROMPT_PROJECT
            [ -z "${PROMPT_PROJECT}" ] || PROJECT="${PROMPT_PROJECT}"
        fi
    fi
    if [ -z "${PROJECT}" ]
    then
        echo "Project name cannot be blank" >/dev/stderr
        return 1
    elif find_project "${PROJECT}"
    then
        echo "Project already exists" >/dev/stderr
        return 1
    elif valid_project_name "${PROJECT}"
    then
        :
    else
        echo "Project name is not valid: ${PROJECT}" >/dev/stderr
        return 1
    fi

    # Parse/prompt for any remote-specific variables
    case "${REMOTE}" in
    github)
        if [ -z "${DESCRIPTION}" ]
        then
            DESCRIPTION=""
            if [ -z "${REMOTE_MANUAL}" ]
            then
                if [ -t 0 ]
                then
                    # Prompt
                    echo -n "Description (\"\"): "
                    read DESCRIPTION
                fi
            fi
        fi
        ;;
    esac

    # Confirmation
    if [ -t 0 ]
    then
        echo "About to create the following project: " >/dev/stderr
        echo "  Remote:        ${REMOTE}" >/dev/stderr
        echo "  Name:          ${PROJECT}" >/dev/stderr
        echo "  Description:   ${DESCRIPTION}" >/dev/stderr
        echo "Please confirm (y/N): "
        read CONFIRM
        [ -n "${CONFIRM}" ] || CONFIRM=n
        if [ \! ${CONFIRM} = "y" ]
        then
            echo "cancelled" >/dev/stderr
            return 1
        fi
    fi

    # Create the empty remote repo
    case "${REMOTE}" in
    burn)
        USER=zachary
        ssh burn git init --bare "/data/git/${PROJECT}.git"
        ;;
    github)
        USER=za3k
        gh repo --new "${PROJECT}" --description "${DESCRIPTION}"
        ;;
    esac

    # Modify the projects file
    set -x
    echo "${REMOTE} ${USER} ${PROJECT}" >>"${PROJECTS}"
    set +x
    inplace_sort "${PROJECTS}"

    # Set the local origin
    PROJECT_REMOTE="$(project_remote_for ${PROJECT})"
    git remote add origin "${PROJECT_REMOTE}"

    # Push all content to the remote repo
    git push -u origin --all

    return 0
}


project_create_help() {
    cat <<EOF
Usage: project create [OPTIONS...] [REMOTE [PROJECT]]
  Move a local git repository to a remote location.

Options
  -n PROJECT        Project name
  -r REMOTE         Remote name, one of: burn github
  -d DESCRIPTION    Project description (github only)
EOF
}
