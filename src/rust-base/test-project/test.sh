#!/bin/bash

set -e
set -u
set -o pipefail

rustup --version
cargo --version
cargo clippy --version
