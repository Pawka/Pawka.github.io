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
tags: [{{TAGS}}]
---"

generate_post() {
    local file=$1

    date=$(basename "$file" | sed 's/\.md$//')
    title=$(grep -m 1 "^# " "$file" | sed 's/^# \+//')
    text=$(sed '0,/^# /{/^# /d;}' "$file")
    tags=$(get_tags "$file")

    echo "$POST_HEADER" \
        | sed "s|{{TITLE}}|$title|" \
        | sed "s|{{DATE}}|$date|" \
        | sed "s|{{TAGS}}|$tags|"
    echo "$text"
}

get_tags() {
    local file=$1
    # Tag pattern.
    readonly pattern=":[^ :]+:"
    # How many lines to check from the beginning of file. Used to reduce false
    # positives from the content such as URLs, etc.
    readonly tags_offset=5

    local header
    header=$(head -n"$tags_offset" "$file")
    if [ -f "$file" ]; then
        if [[ $( echo "$header" | grep -cE "$pattern" || true) != "0" ]]; then
            echo "$header" \
                | grep -oE "$pattern" "$file" \
                | sed "s/://g" \
                | xargs \
                | sed "s/ /,/g"
        fi
    fi
}


# TBA_TAG is used to discard posts from diary. If such tag is found in
# content, the post is not included into the blog.
readonly TBA_TAG=":tba:"

get_content_files() {
    local source_path=$1
    for entry in "$source_path"/*.md
    do
        [[ -e "$entry" ]] || break

        local filename
        filename=$(basename "$entry")

        # Skip vimwiki index page.
        if [[ "$filename" == "diary.md" ]]; then
            continue
        fi

        # Skip TBA posts.
        if [[ $(grep -i "$TBA_TAG" "$entry" -c) != 0 ]]; then
            echo "Skipping. Found $TBA_TAG tag: $entry" >&2
            continue
        fi

        echo "$entry"
    done
}

main() {
    local source_path=$1
    local dest_path=$2

    rm -rf "${dest_path:?}/*"
    mkdir -p "$dest_path"

    for path in $(get_content_files "$source_path"); do
        local filename
        filename=$(basename "$path")
        generate_post "$path" > "$dest_path/$filename"
    done
}

main "$@"
