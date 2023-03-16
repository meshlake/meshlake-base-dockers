#!/bin/bash

set -u

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

OS="$(uname)"
if [[ "${OS}" != "Linux" ]]
then
  abort "The Metaplane CLI is only supported on Linux."
fi

UNAME_MACHINE="$(uname -m)"
if [[ "${UNAME_MACHINE}" == "x86_64" ]]
then
  DOWNLOAD_URL="https://cli.metaplane.dev/download/linux-x64/metaplane"
elif [[ "${UNAME_MACHINE}" == "arm64" ]]
then
  DOWNLOAD_URL="https://cli.metaplane.dev/download/linux-arm64/metaplane"
fi

LOCAL_BIN=/usr/local/bin
mkdir -p $LOCAL_BIN

echo "Downloading the Metaplane CLI binary for Linux $UNAME_MACHINE..."

curl -LSs $DOWNLOAD_URL -o $LOCAL_BIN/metaplane

if [ $? -ne 0 ]; then
  abort "Failed to download the Metaplane CLI binary"
fi

chmod +x $LOCAL_BIN/metaplane

if ! command -v metaplane >/dev/null 2>&1; then
  export PATH=$LOCAL_BIN:$PATH
fi

echo "The Metaplane CLI has been installed to $LOCAL_BIN/metaplane and added to the PATH"
