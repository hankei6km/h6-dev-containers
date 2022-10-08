ARG BASIC_IMAGE=ghcr.io/hankei6km/h6-dev-containers:basic
FROM ${BASIC_IMAGE} as python

ENV H6_IMAGE_TYPE=python

ARG PYTHON_PATH=/usr/local/python
ENV PIPX_HOME=/usr/local/py-utils \
    PIPX_BIN_DIR=/usr/local/py-utils/bin
ENV PATH=${PYTHON_PATH}/bin:${PATH}:${PIPX_BIN_DIR}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=vscode

USER root

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN apt-get update \
  && apt-get -y install --no-install-recommends pkg-config \
  # install python
  && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/python-debian.sh")" -- "latest" "${PYTHON_PATH}" "${PIPX_HOME}" \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

USER "${USERNAME}"