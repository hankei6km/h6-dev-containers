ARG BASIC_IMAGE=ghcr.io/hankei6km/h6-dev-containers:basic
FROM ${BASIC_IMAGE} as dind

ENV H6_IMAGE_TYPE=dind

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ENV DOCKER_BUILDKIT=1
RUN apt-get update \
  # Install Docker
  && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/docker-in-docker-debian.sh")" \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

USER vscode

ENTRYPOINT ["/usr/local/share/docker-init.sh"]
VOLUME [ "/var/lib/docker" ]
CMD ["sleep", "infinity"]