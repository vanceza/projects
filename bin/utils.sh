move_all_contents() {
    for x in "$1"/* "$1"/.[!.]* "$1"/..?*; do
      if [ -e "$x" ]; then mv -- "$x" "$2"/; fi
    done
}

is_function() {
    type "$1" 2>/dev/null | grep -i function >/dev/null
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
