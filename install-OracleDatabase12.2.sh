#!/bin/bash
set -eu -o pipefail

if [[ -z "${MEDIA:-}" ]]; then
  echo "MEDIA is not defined."
  exit 1
fi

sudo yum -y install unzip

readonly TEMP_DIR=$(mktemp -d)
chmod 755 "$TEMP_DIR"
curl -sSL https://github.com/shakiyam/vagrant-oracle12.2/archive/master.tar.gz \
  | tar xzf - -C "$TEMP_DIR" --strip=1
unzip "${MEDIA}/linuxx64_12201_database.zip" -d "$TEMP_DIR"
cd "$TEMP_DIR"
sudo ./setup.sh
rm -rf "$TEMP_DIR"
