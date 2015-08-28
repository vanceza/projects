project_remote_for() {
    if [ $# -ne 1 ]
    then
        project_help "remote-for"
        exit 1
    fi
    PROJECT="$1"
    if [ -z "$PROJECTS" ]
    then
        PROJECTS="${PROJECTS_METADATA_DIR}/PROJECTS"
    fi
    cat "$PROJECTS" | while read LINE
    do
        if [ "$(awk '{ print $3 }')" = "$PROJECT" ]
        then

        fi
    done
}

project_remote_for_help() {

}
