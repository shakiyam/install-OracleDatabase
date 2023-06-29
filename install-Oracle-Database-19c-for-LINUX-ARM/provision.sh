#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR

# load environment variables from .env
set -a
if [ -e "$SCRIPT_DIR"/.env ]; then
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR"/.env
else
  echo 'Environment file .env not found. Therefore, dotenv.sample will be used.'
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR"/dotenv.sample
fi
set +a

readonly FILE="$MEDIA/LINUX.ARM64_1919000_db_home.zip"
if [[ ! -f "$FILE" ]]; then
  echo "$FILE not found"
  exit 1
fi

# Install Oracle Preinstallation RPM
sudo dnf -y install oracle-database-preinstall-19c

# Create directories
sudo mkdir -p "$ORACLE_HOME"
sudo chown -R oracle:oinstall "$ORACLE_BASE"/..
sudo chmod -R 775 "$ORACLE_BASE"/..

# Set environment variables
sudo tee -a /home/oracle/.bash_profile <<EOT
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORACLE_SID=$ORACLE_SID
export PATH=\$PATH:\$ORACLE_HOME/bin:\$ORACLE_HOME/jdk/bin
EOT

# Set oracle password
echo oracle:"$ORACLE_PASSWORD" | sudo chpasswd

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
chmod 755 "$TEMP_DIR"

# Unzip downloaded Oracle Database software
sudo su - oracle -c "unzip -d $ORACLE_HOME $FILE"

# Install Mo (https://github.com/tests-always-included/mo)
curl -sSL https://git.io/get-mo | sudo tee /usr/local/bin/mo >/dev/null
sudo chmod +x /usr/local/bin/mo

# Install Oracle Database
mo "$SCRIPT_DIR"/db_install.rsp.mustache >"$TEMP_DIR"/db_install.rsp
set +e +o pipefail
sudo su - oracle -c "cd $ORACLE_HOME && ./runInstaller -silent \
  -ignorePrereq -waitforcompletion -responseFile $TEMP_DIR/db_install.rsp"
set -e -o pipefail
sudo "$ORACLE_BASE"/../oraInventory/orainstRoot.sh
sudo "$ORACLE_HOME"/root.sh

# Create a listener using netca
sudo su - oracle -c "netca -silent -responseFile $ORACLE_HOME/assistants/netca/netca.rsp"

# Create a database
mo "$SCRIPT_DIR"/dbca.rsp.mustache >"$TEMP_DIR"/dbca.rsp
sudo su - oracle -c "dbca -silent -createDatabase -responseFile $TEMP_DIR/dbca.rsp"

rm -rf "$TEMP_DIR"
