project_rm() {
    unset PROJECT
    unset FORCE
    unset ARCHIVE
    NARGS=0
    while [ $# -gt 0 ]
    do
        case "$1" in
        -f|--force)
            FORCE=yes
            ;;
        *)
            if [ -z "${PROJECT}" ]
            then
                PROJECT="$1"
            else
                project_help archive
            fi
            NARGS=$((NARGS+1))
            ;;
        esac
        shift
    done
    if [ $NARGS -ne 1 ]
    then
      project_help archive
      exit 1
    fi
    
    SOURCE_DIR="${PROJECTS_HOME}/${PROJECT}"
    ARCHIVE_DIR="${PROJECTS_ARCHIVE_DIR}/${PROJECT}"
    case $(project_status "${PROJECT}") in
    invalid)
        project_status -v "${PROJECT}" | tail -n+2
        echo "Will not delete project in an invalid state"
        exit 1
        ;;
    archived)
        echo "Deleting archive" >/dev/stderr
        rm -fr "${ARCHIVE_DIR}"
        ;;
    clean)
        echo "Deleting project" >/dev/stderr
        rm -fr "${SOURCE_DIR}"
        ;;
    dirty)
        if [ -n "${FORCE}" ]
        then
            echo "Deleting project" >/dev/stderr
            rm -fr "${SOURCE_DIR}"
        else
            echo "Refusing to delete project with local changes"
            exit 2
        fi
        ;;
    empty)
        [ -d "${SOURCE_DIR}" ] && {
            echo "Deleting (empty) project folder" >/dev/stderr
            rmdir "${SOURCE_DIR}"
        }
        ;;
    *)
        echo "Unknown status"
        exit 1
        ;;
    esac
}

project_rm_help() {
    cat <<EOF
Usage: project rm [-f] PROJECT
  Removes a project and archive

  Options:
    -f      Remove the project even if there are unsaved changes
EOF
}
