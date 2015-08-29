project_list() {
    awk '{ print $3 }' <"${PROJECTS}" | sort | column
}

project_list_help() {
    cat <<EOF
Usage: project list
  Lists projects
EOF
}
