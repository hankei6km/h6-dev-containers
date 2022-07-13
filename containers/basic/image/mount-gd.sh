#!/bin/bash
set -e

LABEL="devcontainer"

function usage {
    echo "mount-gd <mount point>"
}

if test -z "${1}" ; then
    usage
    exit 1
fi

if test -n "${GDFUSE_SA}" ; then
    echo "${GDFUSE_SA}" > "${HOME}/gd-sa-cred.json"
    google-drive-ocamlfuse -label "${LABEL}" \
        -serviceaccountpath "${HOME}/gd-sa-cred.json" \
        -serviceaccountuser "$(jq -r ".client_email" < "${HOME}/gd-sa-cred.json")" \
        "${1}"
elif test -n "${GDFUSE_CONFIG}"  && test -n "${GDFUSE_STATE}" ; then
    test ! -d "${HOME}/.gdfuse/${LABEL}" && mkdir -p "${HOME}/.gdfuse/${LABEL}"
    echo "${GDFUSE_CONFIG}" > "${HOME}/.gdfuse/${LABEL}/config"
    echo "${GDFUSE_STATE}" > "${HOME}/.gdfuse/${LABEL}/state"
    google-drive-ocamlfuse -label "${LABEL}" "${1}"
fi


# bootstrap 系はファイルを分けるかも
if test -n "${BOOTSTRAP_CODE}" ; then
    source <(echo "${BOOTSTRAP_CODE}")
fi