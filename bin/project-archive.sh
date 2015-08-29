project_archive() {
    if [ $# -ne 1 ]
    then
      project_help archive
      exit 1
    fi
    PROJECT="$1"
    shift 1

    mkdir -p "${PROJECTS_ARCHIVE_DIR}"
    if [ \! -d "${PROJECTS_ARCHIVE_DIR}" ]
    then
        echo "Archive directory does not exist: ${PROJECTS_ARCHIVE_DIR}"
    fi

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
        SOURCE_DIR="${PROJECTS_HOME}/${PROJECT}"
        ARCHIVE_DIR="${PROJECTS_ARCHIVE_DIR}/${PROJECT}"
        mv "${SOURCE_DIR}" "${ARCHIVE_DIR}"
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
Usage: project archive PROJECT
  Archives a project

  Exit codes: 0 (ok), 1 (failure), 2 (not checked out)
EOF
}

