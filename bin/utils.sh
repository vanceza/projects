is_function() {
    type "$1" 2>/dev/null | grep -i function >/dev/null
}

is_command() {
    which "$1" >/dev/null 2>/dev/null
}

echo_verbose() {
    if [ -n "${VERBOSE}" ]
    then
        echo "$@"
    fi
}

is_empty() {
    read TEST_LINE || return 0
    return 1
}

inplace_sort() {
    FILE="$1"
    TMPFILE="$(mktemp)"
    sort "${FILE}" >"${TMPFILE}"
    mv "${TMPFILE}" "${FILE}"
}

parse_project() {
    basename "$1"
}

find_project() {
    while read LINE
    do
        LINE_PROJECT="$(echo "${LINE}" | awk '{ print $3 }')"
        if [ "$1" = "${LINE_PROJECT}" ]
        then
            REMOTE="$(echo "${LINE}" | awk '{ print $1 }')"
            USER="$(echo "${LINE}" | awk '{ print $2 }')"
            return 0
        fi
    done <"${PROJECTS}"
    return 1
}
