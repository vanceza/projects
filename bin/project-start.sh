project_start() {
    unset PROJECT
    ACTION=run
    NARGS=0
    while [ $# -gt 0 ]
    do
        key="$1"
        case "$key" in
        -x|--run|--execute|run|execute|x|r|ru|ex|exe|exec|execu|execut)
            ACTION=run
            ;;
        -e|--edit|edit|e|ed|edi|vim|emacs|nano)
            ACTION=edit
            ;;
        -l|--list|list|l|li|lis)
            ACTION=list
            ;;
        *)
            NARGS=$((NARGS+1))
            if [ "${NARGS}" -eq 1 ]
            then
                PROJECT="${key}"
            fi
            ;;
        esac
        shift
    done
    if [ "${NARGS}" -eq 0 ]
    then
        PROJECT="$(basename "$(pwd)")"
    fi
    if [ "${NARGS}" -gt 1 ]
    then
        project_help start
        exit 1
    fi

    PROJECT_METADATA_DIR="$(project_metadata_dir "${PROJECT}")"
    [ $? -eq 0 ] || return $?
    PROJECT_START_FILE="${PROJECT_METADATA_DIR}/start"

    case $ACTION in 
    run)
        case $(project_status "${PROJECT}") in
        invalid)
            project_status -v "${PROJECT}" | tail -n+2
            return 1
            ;;
        dirty|clean)
            PROJECT_DIR="${PROJECTS_HOME}/${PROJECT}"
            export PROJECT_METADATA_DIR PROJECT_DIR PROJECT

            cd "${PROJECT_DIR}"
            if [ -x "${PROJECT_START_FILE}" ]
            then
                "${PROJECT_START_FILE}"
                return 0
            else
                echo "File does not exist or is not executable: ${PROJECT_START_FILE}" >/dev/stderr
                return 1
            fi
            ;;
        empty|archived)
            echo "${PROJECT} is not checked out"
            return 1
            ;;
        esac
        ;;
    edit)
        START_EDITOR=vim
        [ -n "$EDITOR" ] && START_EDITOR="${EDITOR}"
        "$START_EDITOR" "${PROJECT_START_FILE}"
        return 0
        ;;
    list)
        cat "${PROJECT_START_FILE}"
        return $? 
        ;;
    *)
        echo "Unknown action"
        exit 1
        ;;
    esac
}

project_start_help() {
    cat <<EOF
Usage: project start [ACTION] PROJECT
  Starts a projet

ACTION
  run [DEFAULT] Run the startup file
  edit          Edits the startup file
  list          Display the contents of the startup file
EOF
}
