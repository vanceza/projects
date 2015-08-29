move_all_contents() {
    for x in "$1"/* "$1"/.[!.]* "$1"/..?*; do
      if [ -e "$x" ]; then mv -- "$x" "$2"/; fi
    done
}

project_fetch() {
    if [ $# -ne 1 ]; then project_help fetch; exit 1; fi
    PROJECT="$1"
    shift 1

    ARCHIVE_DIR="${PROJECTS_ARCHIVE_DIR}/${PROJECT}"
    [ -d "${ARCHIVE_DIR}" ] || unset ARCHIVE_DIR
    TARGET_DIR="${PROJECTS_HOME}/${PROJECT}"
    REMOTE="$(project_remote_for "${PROJECT}")"

    case $(project_status "${PROJECT}") in
    invalid)
        project_status -v "${PROJECT}" | tail -n+2
        exit 1
        ;;
    esac

    [ -L "${TARGET_DIR}" ] && TARGET_DIR="$(readlink -e "${TARGET_DIR}")" # Dereference symbolic links

    case $(project_status "${PROJECT}") in
    clean|dirty)
        echo "${TARGET_DIR} is already checked out"
        ;;
    archived)
        echo "Unarchiving"
        if [ -d "${TARGET_DIR}" ]
        then
            move_all_contents "${ARCHIVE_DIR}" "${TARGET_DIR}"
            rmdir "${ARCHIVE_DIR}"
        else
            mv "${ARCHIVE_DIR}" "${TARGET_DIR}"
        fi
        ;;
    empty)
        git clone "${REMOTE}" "${TARGET_DIR}"
        ;;
    esac
}

project_fetch_help() {
    cat <<EOF
Usage: project fetch PROJECT
  Gets a local copy of the git repository. Does not update the repository if it exists.
EOF
}
