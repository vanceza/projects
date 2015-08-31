project_help() {
    SUBJECT=general
    if [ -n "$1" ]; then SUBJECT="$1"; fi
    SUBJECT="$(echo "$SUBJECT" | tr '-' '_')" # Replace - with _ in SUBJECT

    if is_function "project_${SUBJECT}_help"
    then
        "project_${SUBJECT}_help" >/dev/stderr
    else
        echo "No help available on subject: ${SUBJECT}" >/dev/stderr
    fi
    exit 0
}

project_general_help() {
    cat <<EOF
Usage: project <command> args...
  Available commands:
    help [COMMAND]    (current output)
    archive           Archive a project
    create            Make a new project (interactive)
    fetch             Get a local copy of the project
    list              List projects
    start             Start development mode for the project
    status            Check if there are unsaved local changes

    doctor            Make sure there are no missing projects, bad state, etc
    lint              Verify the PROJECTS file is in the correct format
    rm                Delete the project

  (Internal)
    metadata-dir      Print the metadata directory for the project
    remote-for        Print the git remote for the project
EOF
}

project_help_help() {
    cat <<EOF
Usage: project lint [SUBJECT]
  Print help
EOF
}
