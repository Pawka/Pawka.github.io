#!/bin/bash

# Script copies diary entries from vimwiki and converts to Hugo post format by
# pre-pending post meta information to the post file.
#
# - Post date is read from diary filename
# - Post title is the first heading item.
# - The first heading item is removed from post as it will be displayed as
#   title.

set -euo pipefail

readonly POST_HEADER="---
title: \"{{TITLE}}\"
date: {{DATE}}
---"

generate_post() {
    local content=$1

    date=$(basename "$content" | sed 's/\.md$//')
    title=$(grep -m 1 "^# " "$content" | sed 's/^# \+//')
    text=$(sed '0,/^# /{/^# /d;}' "$content")

    echo "$POST_HEADER" \
        | sed "s|{{TITLE}}|$title|" \
        | sed "s|{{DATE}}|$date|"
    echo "$text"
}


# TBA_TAG is used to discard posts from diary. If such tag is found in
# content, the post is not included into the blog.
readonly TBA_TAG=":tba:"

get_content_files() {
    for entry in "$source_path"*.md
    do
        local filename
        filename=$(basename "$entry")

        # Skip vimwiki index page.
        if [[ "$filename" == "diary.md" ]]; then
            continue
        fi

        # Skip TBA posts.
        if [[ $(grep "$TBA_TAG" "$entry" -c) != 0 ]]; then
            continue
        fi

        echo "$entry"
    done
}

main() {
    local source_path=$1
    local dest_path=$2

    rm -rf "$dest_path/*"
    mkdir -p "$dest_path"

    for path in $(get_content_files)
    do
        local filename
        filename=$(basename "$path")
        generate_post "$path" > "$dest_path/$filename"
    done

}

main "$@"
