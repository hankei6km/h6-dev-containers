# この Dev Container は、https://hub.docker.com/_/rust の 1-alpine タグをベースにしている。
# (rust feature は alpine(apk) をサポートしていないため)
# mingw-w64-gcc は arm64(aarch64)用パッケージがなかったので一旦保留。
# (Windos 用のビルドは主に GitHub Actions で行う予定なので、とりあえず)
# 他の variant とは異なるので注意。 
ARG VARIANT="alpine"
FROM rust:1-${VARIANT}

ARG TARGETPLATFORM

RUN apk update \
    # https://github.com/rust-build/rust-build.action/blob/master/Dockerfile
    # Add regular dependencies
    && apk add --no-cache build-base upx \
    # Add windows dependencies
    && if [ "${TARGETPLATFORM}" = "linux/amd64" ] ; then \
      apk add --no-cache mingw-w64-gcc ; \
    fi \
    # Add emscripten dependencies
    # alpine 3.16 ではパッケージがない.
    # && apk add --no-cache emscripten-fastcomp \
    # Add apple dependencies
    && apk add --no-cache clang cmake libxml2-dev \
    openssl-dev musl-fts-dev bsd-compat-headers \
    # Add windows target and toolchain
    && rustup target add x86_64-pc-windows-gnu \
    && rustup toolchain install --force-non-host stable-x86_64-pc-windows-gnu \
    # Add clippy
    && rustup component add clippy

