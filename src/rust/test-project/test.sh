#!/bin/bash

set -e
set -u
set -o pipefail

cargo bump --version
toml --version
