#!/bin/bash
set -eu -o pipefail

if [[ -z "${MEDIA:-}" ]]; then
  echo "MEDIA is not defined."
  exit 1
fi

sudo yum -y install unzip

readonly TEMP_DIR=$(mktemp -d)
chmod 755 "$TEMP_DIR"
curl -sSL https://github.com/shakiyam/vagrant-oracle12.1/archive/master.tar.gz \
  | tar xzf - -C "$TEMP_DIR" --strip=1
unzip "${MEDIA}/linuxamd64_12102_database_1of2.zip" -d "$TEMP_DIR"
unzip "${MEDIA}/linuxamd64_12102_database_2of2.zip" -d "$TEMP_DIR"
pushd "$TEMP_DIR"
sudo ./setup.sh
popd
rm -rf "$TEMP_DIR"
