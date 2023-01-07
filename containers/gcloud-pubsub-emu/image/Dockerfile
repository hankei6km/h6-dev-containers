ARG BASIC_IMAGE=ghcr.io/hankei6km/h6-dev-containers:basic
FROM ${BASIC_IMAGE} as gcloud-pubsub-emu

ENV H6_IMAGE_TYPE=gcloud-pubsub-emu

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=vscode

USER root
# https://cloud.google.com/sdk/docs/install?hl=ja#deb
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.gpg \
    && apt-get update -y \
    # && apt-get install --no-install-recommends -y google-cloud-sdk \
    # && apt-get install --no-install-recommends -y google-cloud-cli google-cloud-cli-pubsub-emulator \
    #
    # google-cloud-* を複数インストールするとエラーになる
    # とりあえず google-cloud-cli-pubsub-emulator のみインストールでエミュレーターは起動できた。
    #
    #  dpkg: error processing archive /var/cache/apt/archives/google-cloud-cli_412.0.0-0_all.deb (--unpack):
    #  trying to overwrite '/usr/share/man/man1/gcloud_alpha_certificate-manager_dns-authorizations_describe.1.gz', which is also in package google-cloud-sdk 412.0.0-0
    # dpkg-deb: error: paste subprocess was killed by signal (Broken pipe)
    # Errors were encountered while processing:
    #  /var/cache/apt/archives/google-cloud-cli_412.0.0-0_all.deb
    # E: Sub-process /usr/bin/dpkg returned an error code (1)
    && apt-get install --no-install-recommends -y google-cloud-cli-pubsub-emulator \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER "${USERNAME}"