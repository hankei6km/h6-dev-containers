ARG BASIC_IMAGE=rust:1-alpine
FROM ${BASIC_IMAGE} as cli_rust

ENV H6_IMAGE_TYPE=cli_rust

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# [Option] Install zsh
ARG INSTALL_ZSH="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN apk update \
    && mkdir -p /tmp/library-scripts \
    && cd /tmp/library-scripts \
    && wget "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-alpine.sh" \
    && ash common-alpine.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" \
    && rm -rf /tmp/library-scripts

# ** [Optional] Uncomment this section to install additional packages. **
RUN apk update \
    # https://github.com/rust-build/rust-build.action/blob/master/Dockerfile
    # Add regular dependencies
    && apk add --no-cache curl jq git build-base bash zip upx \
    # Add windows dependencies
    && apk add --no-cache mingw-w64-gcc \
    # Add emscripten dependencies
    && apk add --no-cache emscripten-fastcomp \
    # Add apple dependencies
    && apk add --no-cache clang cmake libxml2-dev \
      openssl-dev fts-dev bsd-compat-headers xz