project_list() {
    if [ -t 1 ]
    then
        awk '{ print $3 }' <"${PROJECTS}" | sort | column
    else
        awk '{ print $3 }' <"${PROJECTS}" | sort
    fi
}

project_list_help() {
    cat <<EOF
Usage: project list
  Lists projects
EOF
}
