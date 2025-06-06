#!/bin/bash

set -e
set -u
set -o pipefail

source "$(dirname "$0")/util.sh"

USAGE_MSG="Usage: $0 [OPTIONS] -- <variant>
Options:
    -r, --repo       <repo>          Repository name (required)
    -t, --tag        <tag>           Image tag (default: latest)
        --cache-from <cache-from>    Cache source (optional, can be specified multiple times)
        --cache-to   <cache-to>      Cache destination (optional)
    -u, --user       <user>          Custom user for docker login (optional)
        --base-tag-suffix <suffix>   Base tag suffix (default: latest)
Arguments:
    <variant>                        Variant name (required)"

# Parse arguments using getopt
OPTIONS=$(getopt -o r:t:u: --long repo:,tag:,cache-from:,cache-to:,user:,base-tag-suffix: -- "$@")

eval set -- "${OPTIONS}"

REPO=""
TAG="latest"
CACHE_FROM=()
CACHE_TO=""
USER=""
BASE_TAG_SUFFIX="latest"

while true; do
    case "$1" in
    --repo | -r)
        REPO="$2"
        shift 2
        ;;
    --tag | -t)
        TAG="$2"
        shift 2
        ;;
    --cache-from)
        CACHE_FROM+=("$2")
        shift 2
        ;;
    --cache-to)
        CACHE_TO="$2"
        shift 2
        ;;
    --user | -u)
        USER="$2"
        shift 2
        ;;
    --base-tag-suffix)
        BASE_TAG_SUFFIX="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "${USAGE_MSG}"
        exit 1
        ;;
    esac
done

VARIANT="${1:-}"
if [[ -z "$REPO" || -z "$VARIANT" ]]; then
    echo "${USAGE_MSG}"
    exit 1
fi

# Check if USER is empty and exit with an error if not provided
if [[ -z "$USER" ]]; then
    echo "Error: --user argument is required. Please specify a user."
    exit 1
fi

REGISTRY_HOST="$(registry_host)"

if [[ -n "$USER" ]]; then
    echo "${GH_TOKEN}" | docker login "$(registry_host)" -u "$USER" --password-stdin
else
    echo "${GH_TOKEN}" | docker login "$(registry_host)" -u "${GITHUB_ACTOR}" --password-stdin
fi

echo "Setting build arguments in devcontainer.json."

IMAGE_REPO="$(image_repo "${REPO}")"
IMAGE_TAG="$(image_tag "${VARIANT}" "${TAG}")"

TEMP_CONFIG_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_CONFIG_DIR}"' EXIT
TEMP_DEVCONTAINER_JSON="${TEMP_CONFIG_DIR}/.devcontainer/devcontainer.json"
cp -r "./src/${VARIANT}/.devcontainer" "${TEMP_CONFIG_DIR}/"
./scripts/image_set_build_args.sh "./src/${VARIANT}/.devcontainer/devcontainer.json" "${IMAGE_REPO}" "${BASE_TAG_SUFFIX}" \
    >"${TEMP_DEVCONTAINER_JSON}"

echo "Pushing ${REPO}:${IMAGE_TAG} to ${REGISTRY_HOST}"

DEVCONTAINER_ARGS=(
    --remove-existing-container "true"
    --workspace-folder "./src/${VARIANT}/"
    --config "${TEMP_DEVCONTAINER_JSON}"
)

if [[ "${#CACHE_FROM[@]}" -gt 0 ]]; then
    for cache in "${CACHE_FROM[@]}"; do
        DEVCONTAINER_ARGS+=(--cache-from "$cache")
    done
fi

if [[ -n "$CACHE_TO" ]]; then
    DEVCONTAINER_ARGS+=(--cache-to "$CACHE_TO")
fi

# Run devcontainer up and capture the JSON output
DEVCONTAINER_OUTPUT=$(devcontainer up "${DEVCONTAINER_ARGS[@]}")

# Extract the containerId from the JSON output and set it to $CONTAINER_ID
CONTAINER_ID=$(echo "$DEVCONTAINER_OUTPUT" | jq -r '.containerId')

if [[ -z "$CONTAINER_ID" ]]; then
    echo "Error: Failed to retrieve containerId from devcontainer up output."
    exit 1
fi

DEVCONTAINER_EXEC_ARGS=(
    --workspace-folder "./src/${VARIANT}/"
    --config "${TEMP_DEVCONTAINER_JSON}"
    --remote-env "DOCKER_DEFAULT_PLATFORM=${DOCKER_DEFAULT_PLATFORM}"
    "./test-project/test.sh"
)

devcontainer exec "${DEVCONTAINER_EXEC_ARGS[@]}"

docker stop "$CONTAINER_ID"
docker rm "$CONTAINER_ID"
