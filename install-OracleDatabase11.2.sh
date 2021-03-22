#!/bin/bash
set -eu -o pipefail

if [ -e .env ]; then
  # shellcheck disable=SC1091
  . .env
else
  echo 'Environment file .env not found.'
  exit 1
fi

sudo yum -y install unzip

readonly TEMP_DIR=$(mktemp -d)
chmod 755 "$TEMP_DIR"
curl -sSL https://github.com/shakiyam/vagrant-oracle11.2/archive/master.tar.gz \
  | tar xzf - -C "$TEMP_DIR" --strip=1
unzip "${MEDIA}/linux.x64_11gR2_database_1of2.zip" -d "$TEMP_DIR"
unzip "${MEDIA}/linux.x64_11gR2_database_2of2.zip" -d "$TEMP_DIR"
cd "$TEMP_DIR"
sudo ./setup.sh
rm -rf "$TEMP_DIR"
