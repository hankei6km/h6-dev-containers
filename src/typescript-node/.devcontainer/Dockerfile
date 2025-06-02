ARG BASE_REPO="ghcr.io/hankei6km/h6-dev-containers"
ARG BASE_TAG_SUFFIX="latest"
FROM ${BASE_REPO}:node_${BASE_TAG_SUFFIX}

# Install tslint, typescript. eslint is installed by node-latest variant.
# https://github.com/devcontainers/images/blob/a5fe28bee4dd323acc53d2d3702e6f2ca00d4182/src/typescript-node/.devcontainer/Dockerfile#L4-L7
# npm -g install と npm cache clean でユーザー違うけど、そういもの？
# source nvm.sh だと挙動が違うとか？
# $ docker run --rm -it ghcr.io/hankei6km/test-dev-containers-images:typescript-node-topic_add-typescript-node-variant-2025-05-02 du -sh /root/.npm
# 20K     /root/.npm
# $ docker run --rm -it ghcr.io/hankei6km/test-dev-containers-images:typescript-node-topic_add-typescript-node-variant-2025-05-02 du -sh /home/devcontainer/.npm
# 53M     /home/devcontainer/.npm
ARG NODE_MODULES="tslint-to-eslint-config typescript"
RUN su devcontainer -c "umask 0002 && source /usr/local/share/nvm/nvm.sh && npm install -g ${NODE_MODULES}" \
    && npm cache clean --force > /dev/null 2>&1

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment if you want to install an additional version of node using nvm
# ARG EXTRA_NODE_VERSION=10
# RUN su node -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION}"

# [Optional] Uncomment if you want to install more global node packages
# RUN su node -c "npm install -g <your-package-list -here>"
