ARG BASIC_IMAGE=rust:1-alpine
FROM ${BASIC_IMAGE} as cli_rust

ENV H6_IMAGE_TYPE=cli_rust

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# [Option] Install zsh
ARG INSTALL_ZSH="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG DEFAULT_USERNAME=vscode
ARG DEFAULT_USER_UID=1000
ARG DEFAULT_USER_GID=$DEFAULT_USER_UID

ARG RUNNER_USERNAME=runner
ARG RUNNER_USER_UID=1001
ARG RUNNER_USER_GID=$RUNNER_USER_UID

RUN apk update \
    && mkdir -p /tmp/library-scripts \
    && cd /tmp/library-scripts \
    && wget "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-alpine.sh" \
    && ash common-alpine.sh "${INSTALL_ZSH}" "${DEFAULT_USERNAME}" "${DEFAULT_USER_UID}" "${DEFAULT_USER_GID}" \
    && ash common-alpine.sh "${INSTALL_ZSH}" "${RUNNER_USERNAME}" "${RUNNER_USER_UID}" "${RUNNER_USER_GID}" \
    && rm -rf /tmp/library-scripts

# ** [Optional] Uncomment this section to install additional packages. **
RUN apk update \
    # https://github.com/rust-build/rust-build.action/blob/master/Dockerfile
    # Add regular dependencies
    && apk add --no-cache curl jq git build-base bash zip upx \
    # Add windows dependencies
    && apk add --no-cache mingw-w64-gcc \
    # Add emscripten dependencies
    # alpine 3.16 ではパッケージがない.
    # && apk add --no-cache emscripten-fastcomp \
    # Add apple dependencies
    && apk add --no-cache clang cmake libxml2-dev \
      openssl-dev fts-dev bsd-compat-headers xz \
    # Add windows target and toolchain
    && rustup target add x86_64-pc-windows-gnu \
    && rustup toolchain install stable-x86_64-pc-windows-gnu \
    # Add clippy
    && rustup component add clippy

# DevContainer CLI では動いても GitHub Actions ではエラーになるので一旦保留。
#
# # image 作成時、 root で cargo install するとコンテナ内で user が build するとエラーになる。
# # 理由は不明。
# #
# #   Downloaded cfg-if v1.0.0                                                                                               
# # error: failed to open `/usr/local/cargo/registry/cache/github.com-1ecc6299db9ec823/cfg-if-1.0.0.crate`
# # 
# # Caused by:
# #   Permission denied (os error 13)
# 
# USER "${DEFAULT_USERNAME}"
# 
# RUN cargo install cargo-license
# 
# USER root