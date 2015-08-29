project_help() {
    SUBJECT=general
    if [ -n "$1" ]; then SUBJECT="$1"; fi
    SUBJECT="$(echo "$SUBJECT" | tr '-' '_')" # Replace - with _ in SUBJECT
    case $SUBJECT in
    general)
        project_general_help >/dev/stderr
        exit 1
        ;;
    archive|fetch|help|lint|list|rm|remote-for)
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
    list              List projects
    lint              Verify the PROJECTS file is in the correct format
    fetch             Get a local copy of the project
    start             Start development mode for the project
    check             Check if there are unsaved local changes
    rm                Delete the project
    create            Make a new project (interactive)

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
