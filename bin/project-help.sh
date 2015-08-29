project_help() {
    SUBJECT=general
    if [ -n "$1" ]; then SUBJECT="$1"; fi
    SUBJECT="$(echo "$SUBJECT" | tr '-' '_')" # Replace - with _ in SUBJECT
    case $SUBJECT in
    general)
        project_general_help >/dev/stderr
        exit 1
        ;;
    archive|fetch|help|lint|list|rm|remote-for|status)
        project_${SUBJECT}_help >/dev/stderr
        ;;
    *)
        echo "No help available on subject: ${SUBJECT}" >/dev/stderr
    esac
    exit 0
}

project_general_help() {
    cat <<EOF
Usage: project <command> args...
  Available commands:
    help [COMMAND]    (current output)
    archive           Archive a project
    check             Check if there are unsaved local changes
    create            Make a new project (interactive)
    fetch             Get a local copy of the project
    list              List projects
    start             Start development mode for the project

    lint              Verify the PROJECTS file is in the correct format
    rm                Delete the project

  (Internal)
    remote-for        Git remote for the project
EOF
}

project_help_help() {
    cat <<EOF
Usage: project lint [SUBJECT]
  Print help
EOF
}
