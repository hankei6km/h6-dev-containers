ARG BASE_REPO="ghcr.io/hankei6km/h6-dev-containers"
ARG BASE_TAG_SUFFIX="latest"

FROM ${BASE_REPO}:rust-base_${BASE_TAG_SUFFIX} AS build

RUN cargo install cargo-bump toml-cli 

FROM ${BASE_REPO}:rust-base_${BASE_TAG_SUFFIX}

COPY --from=build /usr/local/cargo/bin/cargo-bump /usr/local/bin/cargo-bump
COPY --from=build /usr/local/cargo/bin/toml /usr/local/bin/toml
