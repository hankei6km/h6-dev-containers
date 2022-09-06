# https://github.com/microsoft/vscode-dev-containers/tree/main/containers/debian

# [Choice] Ubuntu version (use ubuntu-22.04 or ubuntu-18.04 on local arm64/Apple Silicon): ubuntu-22.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT=ubuntu

FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT} as gh-extension

ARG USERNAME=vscode

ARG GITHUB_TOKEN=""
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog curl ca-certificates software-properties-common 2>&1 \
    && apt-get update \
    # https://github.com/cli/cli/issues/6175#issuecomment-1235984381
    # Install GihHub CLI
    && curl -s https://api.github.com/repos/cli/cli/releases/latest | jq .assets[].browser_download_url | grep linux_amd64.deb | xargs -I '{}' curl -sL -o /tmp/ghcli.deb '{}' \
    && dpkg -i /tmp/ghcli.deb \
    && rm /tmp/ghcli.deb \
    && apt-get install -y --no-install-recommends  $devToolsPkgs $guiDeps $serverPkgs \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR "/home/${USERNAME}"
USER ${USERNAME}

RUN gh extension install actions/gh-actions-cache


FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT} as basic

ENV H6_IMAGE_TYPE=basic

ARG USERNAME=vscode

ENV NVM_DIR="/usr/local/share/nvm"
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog wget ca-certificates software-properties-common 2>&1 \
    && apt-get update \
    #
    # Install dev tools(editor, dvcs, etc) into global environment.
    && export devToolsPkgs=' \
      bash-completion \
      bc \
      curl \
      libimage-exiftool-perl \
      file \
      git \
      iputils-ping \
      netbase \
      net-tools\
      nkf \
      python3-pip \
      ranger \
      shellcheck \
      sudo \
      tig \
      tmux \
      unzip \
      vim \
      w3m \
    ' \
    && apt-get install -y --no-install-recommends  $devToolsPkgs $guiDeps $serverPkgs \
    #
    # Install up google-drive-ocamlfuse
    && add-apt-repository -y ppa:alessandro-strada/ppa \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y google-drive-ocamlfuse \
    # https://github.com/cli/cli/issues/6175#issuecomment-1235984381
    # Install GihHub CLI
    && curl -s https://api.github.com/repos/cli/cli/releases/latest | jq .assets[].browser_download_url | grep linux_amd64.deb | xargs -I '{}' curl -sL -o /tmp/ghcli.deb '{}' \
    && dpkg -i /tmp/ghcli.deb \
    && rm /tmp/ghcli.deb \
    #
    # install Node.js
    && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/node-debian.sh")" -- "${NVM_DIR}" \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# [Optional] Uncomment if you want to install an additional version of node using nvm
# ARG EXTRA_NODE_VERSION=14
# RUN su node -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION}"

# [Optional] Uncomment if you want to install more global node packages
# RUN su node -c "npm install -g <your-package-list -here>"
# RUN su "${USERNAME}" -c "npm install -g zx guratan"


# Prepeare gdfuse to user environment
COPY --chown="${USERNAME}" --chmod=755 mount-gd.sh "/home/${USERNAME}/mount-gd.sh"

WORKDIR "/home/${USERNAME}"
USER ${USERNAME}
COPY vimrc "/home/${USERNAME}/.vimrc"

# Setup user environment
RUN mkdir -p "/home/${USERNAME}/.local/share" \
    # Install npm pacakges to global
    && npm install -g zx @devcontainers/cli \
    # Setup actionlint for user. \
    && mkdir -p "/home/${USERNAME}/.local/bin" \
    && curl -s https://api.github.com/repos/rhysd/actionlint/releases/latest | jq .assets[].browser_download_url | grep linux_amd64 | xargs -I '{}' curl -sL '{}' | tar -zxf - -C "/home/${USERNAME}/.local/bin" actionlint \
    # Setup vim for user. \
    && mkdir -p "/home/${USERNAME}/.vim" \
    && git clone https://github.com/VundleVim/Vundle.vim.git /home/${USERNAME}/.vim/bundle/Vundle.vim \
    && vim +PluginInstall +qall \
    mkdir -p /home/${USERNAME}/.vim/pack/git-plugins/start \
    && vim "+silent! helptags ALL" +qall \
    # Setup fzf(temporaly).  \
    && git clone https://github.com/junegunn/fzf.git --depth 1 "/home/${USERNAME}/.fzf" \
    && "/home/${USERNAME}/.fzf/install" --key-bindings --completion --update-rc \
    # Setup mirage_linemode
    && pip install --no-cache-dir mirage_linemode \
    && export PATH="/home/${USERNAME}/.local/bin:${PATH}" \
    #&& ranger --copy-config = all \
    && mkdir -p "/home/${USERNAME}/.config/ranger/plugins" \
    && mirage_linemode_ctrl init \
    && mirage_linemode_ctrl enable \
    # Mount google drive then start bootstrap code
    && mkdir -p "/home/${USERNAME}/gdrive" \
    && test -d "/home/${USERNAME}/.local/bin" || mkdir -p "/home/${USERNAME}/.local/bin" \
    && mv "/home/${USERNAME}/mount-gd.sh" "/home/${USERNAME}/.local/bin/mount-gd.sh" \
    # Prepare to copy from GitHubCLI extentkions
    && mkdir -p "/home/${USERNAME}/.local/share/gh"

COPY --from=gh-extension "/home/${USERNAME}/.local/share/gh/extensions" "/home/${USERNAME}/.local/share/gh/extensions"
COPY mirage_linemode "/home/${USERNAME}/.config"

# USER root

# Switch back to dialog for any ad-hoc use of apt-get
# ENV DEBIAN_FRONTEND=dialog

