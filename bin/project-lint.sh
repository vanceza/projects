project_lint() {
    if [ -n "$1" ]; then PROJECTS="$1"; shift; fi
    STATUS=0
    if sort -C "${PROJECTS}"
    then
        :
    else
        echo "${PROJECTS} is not sorted"
        STATUS=1
    fi

    awk -e '{ print $1 }' "${PROJECTS}" | while read REPO
    do
        case $REPO in
        github)
            ;;
        burn)
            ;;
        *)
            echo "Repo was: ${REPO}"
            echo "Repo must be one of: burn github"
            STATUS=1
        esac
    done

    awk -e '{ print $3 }' "${PROJECTS}"  | sort | uniq -d | while read DUPLICATE
    do
        echo "Project ${DUPLICATE} appears in more than one line"
        STATUS=1
    done

    if [ ${STATUS} -eq 0 ]
    then
        echo "valid"
    fi
    return ${STATUS}
}

project_lint_help() {
    cat <<EOF
Usage: project lint [FILE]
  Lint the project file and ensure it is valid
EOF
}
