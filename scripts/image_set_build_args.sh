#!/bin/bash
set -e
set -u
set -o pipefail

strip-json-comments <"${1}" |
    jq -r --arg baseRepo "${2}" --arg baseTagSuffix "${3}" \
        '.build.args.BASE_REPO = $baseRepo | .build.args.BASE_TAG_SUFFIX = $baseTagSuffix'
