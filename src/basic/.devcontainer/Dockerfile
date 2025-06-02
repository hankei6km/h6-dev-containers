ARG VARIANT="noble"
FROM buildpack-deps:${VARIANT}-curl

LABEL dev.containers.features="common"

ARG VARIANT
RUN if [ "$VARIANT" = "noble" ]; then \
    if id "ubuntu" &>/dev/null; then \
    echo "Deleting user 'ubuntu'  for $VARIANT" && userdel -f -r ubuntu || echo "Failed to delete ubuntu user for $VARIANT"; \  
    else \
    echo "User 'ubuntu' does not exist for $VARIANT"; \ 
    fi; \
    fi

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# - shellcheck をインストール
# - actionlint をインストール(https://github.com/rhysd/actionlint/blob/v1.7.7/docs/install.md#download-script)
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends shellcheck \
    && mkdir -m 0700 -p /tmp/actionlint \
    && curl -o /tmp/actionlint/download-actionlint.bash https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash \
    && bash /tmp/actionlint/download-actionlint.bash latest /usr/local/bin \
    && rm -r /tmp/actionlint
