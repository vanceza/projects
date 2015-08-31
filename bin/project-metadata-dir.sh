project_metadata_dir() {
    if [ $# -ne 1 ]
    then
        project_help metadata-dir
        exit 1
    fi
    PROJECT="$1"
    shift 1

    mkdir -p "${PROJECTS_METADATA_DIR}" || {
        echo "Metadata directory does not exist: ${PROJECTS_METADATA_DIR}"
        exit 1
    }

    SKEL_METADATA_DIR="${PROJECTS_METADATA_DIR}/skel"
    if [ \! -e "${SKEL_METADATA_DIR}" ]
    then
        SKEL_SOURCE_DIR="$(dirname "$0")/../skel"
        if [ -e "${SKEL_SOURCE_DIR}" ]
        then
            cp -r "${SKEL_SOURCE_DIR}" "${SKEL_METADATA_DIR}"
        fi
    fi

    PROJECT_METADATA_DIR="${PROJECTS_METADATA_DIR}/${PROJECT}"
    if [ \! -d "${PROJECT_METADATA_DIR}" ]
    then
        if [ -e "${SKEL_METADATA_DIR}" ]
        then
            cp -r "${SKEL_METADATA_DIR}" "${PROJECT_METADATA_DIR}" || {
                echo "Could not create metadata directory: ${PROJECT_METADATA_DIR}"
                exit 1
            }
        else
            mkdir "${PROJECT_METADATA_DIR}" || {
                echo "Could not create metadata directory: ${PROJECT_METADATA_DIR}"
                exit 1
            }
        fi
    fi

    mkdir -p "${PROJECT_METADATA_DIR}" || {
        echo "Could not create metadata directory: ${PROJECT_METADATA_DIR}"
        exit 1
    }

    echo "${PROJECT_METADATA_DIR}"
}

project_metadata_dir_help() {
    cat <<EOF
Usage: project metadata-dir PROJECT
  Returns the directory where the project's metadata is located.

  May make the directory (by copying a skeleton directory) if needed
EOF
}
