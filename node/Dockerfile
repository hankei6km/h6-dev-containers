ARG BASIC_IMAGE=ghcr.io/hankei6km/my-images-codespaces:basic
FROM ${BASIC_IMAGE} as node

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=vscode

USER root

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment if you want to install an additional version of node using nvm
ARG EXTRA_NODE_VERSION=14
RUN su "${USERNAME}" -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION} && nvm use default"

# [Optional] Uncomment if you want to install more global node packages
# RUN su node -c "npm install -g <your-package-list -here>"

USER "${USERNAME}"