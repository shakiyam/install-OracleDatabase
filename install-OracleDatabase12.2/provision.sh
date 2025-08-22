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

readonly FILE="$MEDIA/V839960-01.zip"
if [[ ! -f "$FILE" ]]; then
  echo "$FILE not found"
  exit 1
fi

# Install Oracle Preinstallation RPM
sudo yum -y install oracle-database-server-12cR2-preinstall

# Create directories
sudo mkdir -p "$ORACLE_BASE"/..
sudo chown -R oracle:oinstall "$ORACLE_BASE"/..
sudo chmod -R 775 "$ORACLE_BASE"/..

# Set environment variables
sudo tee -a /home/oracle/.bash_profile <<EOT
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORACLE_SID=$ORACLE_SID
export PATH=\$PATH:\$ORACLE_HOME/bin:\$ORACLE_HOME/jdk/bin
EOT

# Install rlwrap and set alias
# shellcheck disable=SC1091
OS_VERSION=$(. /etc/os-release && echo "$VERSION")
readonly OS_VERSION
case ${OS_VERSION%%.*} in
  7)
    sudo yum -y --enablerepo=ol7_developer_EPEL install rlwrap
    sudo tee -a /home/oracle/.bashrc <<EOT >/dev/null
alias sqlplus='rlwrap sqlplus'
EOT
    ;;
esac

# Set oracle password
echo oracle:"$ORACLE_PASSWORD" | sudo chpasswd

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
chmod 755 "$TEMP_DIR"

# Unzip downloaded Oracle Database software
unzip -d $TEMP_DIR $FILE

# Install Mo (https://github.com/tests-always-included/mo)
curl -fL# https://github.com/tests-always-included/mo/archive/refs/tags/3.0.5.tar.gz \
  | tar xzf - -O mo-3.0.5/mo | sudo install -m 755 /dev/stdin /usr/local/bin/mo

# Install Oracle Database
mo "$SCRIPT_DIR"/db_install.rsp.mustache >"$TEMP_DIR"/db_install.rsp
sudo su - oracle -c "$TEMP_DIR/database/runInstaller -silent -showProgress \
  -ignorePrereq -waitforcompletion -responseFile $TEMP_DIR/db_install.rsp"
sudo "$ORACLE_BASE"/../oraInventory/orainstRoot.sh
sudo "$ORACLE_HOME"/root.sh

# Create a listener using netca
sudo su - oracle -c "netca -silent -responseFile $ORACLE_HOME/assistants/netca/netca.rsp"

# Create a database
mo "$SCRIPT_DIR"/dbca.rsp.mustache >"$TEMP_DIR"/dbca.rsp
sudo su - oracle -c "dbca -silent -createDatabase -responseFile $TEMP_DIR/dbca.rsp"

rm -rf "$TEMP_DIR"
