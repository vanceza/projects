project_rm() {
    echo "rm is incomplete" >/dev/stderr
    exit 1
}

project_rm_help() {
    cat <<EOF
    INCOMPLETE!!
Usage: project rm PROJECT
  Removes a project

  Options:
    -f      Remove the project even if there are unsaved changes
EOF
}
