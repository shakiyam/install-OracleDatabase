#!/bin/bash
set -eu -o pipefail

if [ -e .env ]; then
  # shellcheck disable=SC1091
  . .env
fi

sudo yum -y install git unzip

git clone https://github.com/shakiyam/vagrant-oracle11.2
cd vagrant-oracle11.2
unzip "${MEDIA}/linux.x64_11gR2_database_1of2.zip"
unzip "${MEDIA}/linux.x64_11gR2_database_2of2.zip"
sudo ./setup.sh
