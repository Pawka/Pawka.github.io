#!/bin/bash

# Script copies diary entries from vimwiki and converts to Hugo post format by
# pre-pending post meta information to the post file.
#
# - Post date is read from diary filename
# - Post title is the first heading item.
# - The first heading item is removed from post as it will be displayed as
#   title.

set -xeuo pipefail

readonly POST_HEADER="---
title: \"{{TITLE}}\"
date: {{DATE}}
---"

generate_post() {
    local content=$1

    date=$(basename "$entry" | sed 's/\.md$//')
    title=$(grep -m 1 "^# " "$content" | sed 's/^# \+//')
    text=$(sed '0,/^# /{/^# /d;}' "$content")

    echo "$POST_HEADER" \
        | sed "s|{{TITLE}}|$title|" \
        | sed "s|{{DATE}}|$date|"
    echo "$text"
}

main() {
    local source_path=$1
    local dest_path=$2

    for entry in $source_path*.md
    do
        filename=$(basename "$entry")
        if [[ "$filename" == "diary.md" ]]; then
            continue
        fi
        generate_post "$entry" > "$dest_path/$filename"
    done

}

main "$@"
