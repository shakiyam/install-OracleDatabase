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

git clone https://github.com/shakiyam/vagrant-oracle12.2
cd vagrant-oracle12.2
unzip "${MEDIA}/linuxx64_12201_database.zip"
sudo ./setup.sh
