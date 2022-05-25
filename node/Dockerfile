# https://github.com/microsoft/vscode-dev-containers/blob/main/containers/typescript-node/.devcontainer/Dockerfile

# [Choice] Node.js version (use -bullseye variants on local arm64/Apple Silicon): 16, 14, 12, 16-bullseye, 14-bullseye, 12-bullseye, 16-buster, 14-buster, 12-buster
ARG VARIANT=dev-16-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:${VARIANT}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog wget ca-certificates software-properties-common 2>&1 \
    # add github cli repo
    # && apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 \
    # && apt-add-repository https://cli.github.com/packages \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    #
    # Tactically remove imagemagick due to https://security-tracker.debian.org/tracker/CVE-2019-10131
    # Can leave in image once the CVE is resolved upstream or the node images move to "buster".
    && apt-get purge -y imagemagick imagemagick-6-common \
    #
    # Install dev tools(editor, dvcs, etc) into global environment.
    && export devToolsPkgs=' \
      bash-completion \
      bc \
      chromium \
      chromium-sandbox \
      fonts-noto-cjk \
      curl \
      libimage-exiftool-perl \
      file \
      gh \
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
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# [Optional] Uncomment if you want to install an additional version of node using nvm
ARG EXTRA_NODE_VERSION=14
RUN su node -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION}"

# [Optional] Uncomment if you want to install more global node packages
# RUN su node -c "npm install -g <your-package-list -here>"
ARG USERNAME=node
RUN su "${USERNAME}" -c "npm install -g eslint zx guratan"


WORKDIR "/home/${USERNAME}"
USER ${USERNAME}
COPY vimrc "/home/${USERNAME}/.vimrc"

RUN mkdir -p "/home/${USERNAME}/.local/share" \
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
    && mirage_linemode_ctrl enable

COPY mirage_linemode "/home/${USERNAME}/.config"

# USER root

# Switch back to dialog for any ad-hoc use of apt-get
# ENV DEBIAN_FRONTEND=dialog

