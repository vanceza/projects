project_archive() {
    if [ $# -eq 0 ]; then
        PROJECT="$(basename "$(pwd)")"
    elif [ $# -eq 1 ]; then
        PROJECT=`parse_project "$1"`
    else
        project_help archive
        exit 1
    fi

    mkdir -p "${PROJECTS_ARCHIVE_DIR}"
    if [ \! -d "${PROJECTS_ARCHIVE_DIR}" ]
    then
        echo "Archive directory does not exist: ${PROJECTS_ARCHIVE_DIR}"
    fi

    local SOURCE_DIR="${PROJECTS_HOME}/${PROJECT}"
    local ARCHIVE_DIR="${PROJECTS_ARCHIVE_DIR}/${PROJECT}"

    case $(project_status "${PROJECT}") in
    invalid)
        project_status -v "${PROJECT}" | tail -n+2
        echo "Will not archive project in an invalid state" >/dev/stderr
        exit 1
        ;;
    empty|archived)
        echo "That project is not checked out" >/dev/stderr
        exit 2
        ;;
    clean)
        if [ -L "${SOURCE_DIR}" ]; then # Delete symlink
          rm "${SOURCE_DIR}"
        else # Move directory, for old projects which were added as directories.
          mv "${SOURCE_DIR}" "${ARCHIVE_DIR}"
        fi
        # Not possible to change directory from this command
        exit 0
        ;;
    dirty)
        echo "The project has uncommitted changes. Please commit your changes first." >/dev/stderr
        exit 1
        ;;
    *)
        echo "other"
        echo " $(project_status "${PROJECT}")"
        exit 1
        ;;
    esac
}

project_archive_help() {
    cat <<EOF
Usage: project archive [PROJECT]
  Archives a project

  Exit codes: 0 (ok), 1 (failure), 2 (not checked out)
EOF
}

