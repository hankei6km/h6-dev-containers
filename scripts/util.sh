#!/bin/bash

set -u

tag_concat_char() {
    echo "_"
}

escape_tag() {
    local tag="${1}"
    local escaped_tag
    escaped_tag=$(echo "${tag}" | sed 's/[^a-zA-Z0-9._-]/_/g')
    echo "${escaped_tag}"
}

branch_name() {
    local github_head_ref="${1}"
    if [ -z "${github_head_ref}" ]; then
        echo "main"
    else
        echo "${github_head_ref//refs\/heads\//}"
    fi
}

registry_host() {
    echo "ghcr.io"
}

image_repo() {
    local repo="${1}"
    echo "$(registry_host)/${repo}/images"
}

image_tag() {
    local tags=()
    for tag in "${@}"; do
        tags+=("$(escape_tag "${tag}")")
    done
    if [ "${#tags[@]}" -eq 1 ]; then
        echo "${tags[0]}$(tag_concat_char)latest"
    elif [ "${#tags[@]}" -eq 2 ]; then
        echo "${tags[0]}$(tag_concat_char)${tags[1]}"
    elif [ "${#tags[@]}" -eq 3 ]; then
        echo "${tags[0]}$(tag_concat_char)${tags[1]}$(tag_concat_char)${tags[2]}"
    else
        echo "Error: Invalid number of arguments" >&2
        return 1
    fi
}

cache_repo() {
    local repo="${1}"
    echo "$(registry_host)/${repo}/cache"
}

cache_tag() {
    image_tag "${@}"
}
