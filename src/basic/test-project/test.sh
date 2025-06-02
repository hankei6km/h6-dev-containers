#!/bin/bash

set -e
set -u
set -o pipefail

EXPECTED_MACHINE=""
case "${DOCKER_DEFAULT_PLATFORM:-}" in
linux/arm64)
    EXPECTED_MACHINE="aarch64"
    ;;
*)
    EXPECTED_MACHINE="x86_64"
    ;;
esac
diff <(uname -m) <(echo "$EXPECTED_MACHINE")

diff <(id -un) <(echo "devcontainer")
git --version
gh --version
shfmt --version
shellcheck --version
actionlint --version
jq --version
