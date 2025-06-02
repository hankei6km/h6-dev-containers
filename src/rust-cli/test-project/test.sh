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
rustup --version
cargo --version
cargo clippy --version

case "${EXPECTED_MACHINE}" in
x86_64)
    command -v x86_64-w64-mingw32-gcc
    ;;
*)
    ;;
esac