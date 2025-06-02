#!/bin/bash

set -e
set -u
set -o pipefail

source /usr/local/share/nvm/nvm.sh
nvm --version
node --version
npm --version
