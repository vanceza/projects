project_help() {
    SUBJECT=main
    if [ -n "$1" ]; then SUBJECT="$1"; fi
    SUBJECT="$(echo "$SUBJECT" | tr '-' '_')" # Replace - with _ in SUBJECT
    case $SUBJECT in
    general)
        project_general_help >/dev/stderr
        exit 1
        ;;
    lint|remote_for|fetch|rm|archive|help)
        project_${SUBJECT}_help >/dev/stderr
        ;;
    esac
    exit 0
}

project_general_help() {
    cat <<EOF
Usage: project <command> args...
  Available commands:
    help [COMMAND]    (current output)
    lint              Verify the PROJECTS file is in the correct format
    fetch             Get a local copy of the project
    start             Start development mode for the project
    check             Check if there are unsaved local changes
    rm                Delete the project
    create            Make a new project (interactive)
EOF
}

project_help_help() {
    cat <<EOF
Usage: project lint [SUBJECT]
  Print help
EOF
}
