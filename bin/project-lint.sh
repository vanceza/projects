project_lint() {
    if [ -n "$1" ]; then PROJECTS="$1"; shift; fi
    STATUS=0
    awk -e '{ print $1 }' "${PROJECTS}" | while read REPO
    do
        case $REPO in
        github)
            ;;
        deadtree)
            ;;
        *)
            echo "Repo was: ${REPO}"
            echo "Repo must be one of: deadtree github"
            STATUS=1
        esac
    done

    awk -e '{ print $3 }' "${PROJECTS}"  | sort | uniq -d | while read DUPLICATE
    do
        echo "Project ${DUPLICATE} appears in more than one line"
        STATUS=1
    done

    echo "valid" >/dev/stderr
    exit $SUCCESS
}

project_lint_help() {
    cat <<EOF
Usage: project lint [FILE]
  Lint the project file and ensure it is valid
EOF
}
