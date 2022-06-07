ARG BASIC_IMAGE=ghcr.io/hankei6km/h6-dev-containers:basic
FROM ${BASIC_IMAGE} as node

ENV H6_IMAGE_TYPE=node

ENV NVM_DIR="/usr/local/share/nvm"
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=vscode

USER root

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN apt-get update \
  # install Node.js
  && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/node-debian.sh")" -- "${NVM_DIR}" \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# [Optional] Uncomment if you want to install an additional version of node using nvm
ARG EXTRA_NODE_VERSION=14
RUN su "${USERNAME}" -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION} && nvm use default"

# [Optional] Uncomment if you want to install more global node packages
# RUN su node -c "npm install -g <your-package-list -here>"

USER "${USERNAME}"