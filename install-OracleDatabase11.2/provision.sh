#!/bin/bash
set -eu -o pipefail

if [[ -z "${MEDIA:-}" ]]; then
  echo "MEDIA is not defined."
  exit 1
fi

declare -r -a FILES=("$MEDIA/p13390677_112040_Linux-x86-64_1of7.zip" "$MEDIA/p13390677_112040_Linux-x86-64_2of7.zip")

for file in "${FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "File not found"
    exit 1
  fi
done

sudo yum -y install unzip

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
chmod 755 "$TEMP_DIR"
curl -sSL https://github.com/shakiyam/vagrant-oracle11.2/archive/master.tar.gz \
  | tar xzf - -C "$TEMP_DIR" --strip=1
printf "%s\n" "${FILES[@]}" | xargs -I{} unzip {} -d "$TEMP_DIR"
pushd "$TEMP_DIR"
sudo ./setup.sh
popd
rm -rf "$TEMP_DIR"
