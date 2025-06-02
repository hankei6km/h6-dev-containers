#!/bin/bash

set -e
set -u
set -o pipefail

source "$(dirname "$0")/util.sh"

USAGE_MSG="Usage: $0 [OPTIONS] -- <variant>
Options:
    -r, --repo       <repo>          Repository name (required)
    -t, --tag        <tag>           Image tag (default: latest)
    -p, --platform   <platforms>     Target platforms (default: linux/amd64,linux/arm64)
        --push       <boolean>       Whether to push the image (default: false)
        --cache-from <cache-from>    Cache source (optional, can be specified multiple times)
        --cache-to   <cache-to>      Cache destination (optional)
    -u, --user       <user>          Custom user for docker login (optional)
        --base-tag-suffix <suffix>   Base tag suffix (default: latest)
Arguments:
    <variant>                        Variant name (required)"

# Parse arguments using getopt
OPTIONS=$(getopt -o r:t:p:u: --long repo:,tag:,platform:,push:,cache-from:,cache-to:,user:,base-tag-suffix: -- "$@")

eval set -- "${OPTIONS}"

REPO=""
TAG="latest"
PLATFORM="linux/amd64,linux/arm64"
PUSH="false"
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
    --platform | -p)
        PLATFORM="$2"
        shift 2
        ;;
    --push)
        PUSH="$2"
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
    echo "${GH_TOKEN}" | docker login "${REGISTRY_HOST}" -u "$USER" --password-stdin
else
    echo "${GH_TOKEN}" | docker login "${REGISTRY_HOST}" -u "${GITHUB_ACTOR}" --password-stdin
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
    --workspace-folder "./src/${VARIANT}/"
    --config "${TEMP_DEVCONTAINER_JSON}"
    --image-name "${IMAGE_REPO}:${IMAGE_TAG}"
    --push "${PUSH}"
    --platform "${PLATFORM}"
)

if [[ "${#CACHE_FROM[@]}" -gt 0 ]]; then
    for cache in "${CACHE_FROM[@]}"; do
        DEVCONTAINER_ARGS+=(--cache-from "$cache")
    done
fi

if [[ -n "$CACHE_TO" ]]; then
    DEVCONTAINER_ARGS+=(--cache-to "$CACHE_TO")
fi

devcontainer build "${DEVCONTAINER_ARGS[@]}"

# "devcontainer build" の "--label" が動作しない \
# おそらくこれ -> https://github.com/devcontainers/cli/issues/930  \
# push.sh でラベルを付ける
#--label "org.opencontainers.image.source=https://github.com/${REPO}" \

# devcontaienr-lock.json が作成されないときは、以下を実行すると作成される。
# 正しい方法であるかは知らない。
# devcontainer upgrade \
#     --workspace-folder "./src/${VARIANT}/" \
#     --config "./src/${VARIANT}/.devcontainer/devcontainer.json" \
