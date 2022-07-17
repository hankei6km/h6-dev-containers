ARG BASIC_IMAGE=ghcr.io/hankei6km/h6-dev-containers:basic
FROM ${BASIC_IMAGE} as rust

ENV H6_IMAGE_TYPE=rust

ENV CARGO_HOME=/usr/local/cargo \
    RUSTUP_HOME=/usr/local/rustup
ENV PATH=${CARGO_HOME}/bin:${PATH}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=vscode

USER root

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN apt-get update \
  # install Rust
  && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/rust-debian.sh")" -- "${CARGO_HOME}" "${RUSTUP_HOME}" \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  # Add clippy
  && rustup component add clippy

USER "${USERNAME}"