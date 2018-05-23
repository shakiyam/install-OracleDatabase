#!/bin/bash
set -eu -o pipefail

if [ -e .env ]; then
  # shellcheck disable=SC1091
  . .env
else
  echo 'Environment file .env not found.'
  exit 1
fi

sudo yum -y install git unzip

git clone https://github.com/shakiyam/vagrant-oracle12.1
cd vagrant-oracle12.1
unzip "${MEDIA}/linuxamd64_12102_database_1of2.zip"
unzip "${MEDIA}/linuxamd64_12102_database_2of2.zip"
sudo ./setup.sh
