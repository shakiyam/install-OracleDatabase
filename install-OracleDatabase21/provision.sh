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

readonly FILE="$MEDIA/LINUX.X64_213000_db_home.zip"
if [[ ! -f "$FILE" ]]; then
  echo "$FILE not found"
  exit 1
fi

# Install Oracle Preinstallation RPM
sudo yum -y install oracle-database-preinstall-21c

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

# Install the Sample Schemas
if [[ ${ORACLE_SAMPLESCHEMA^^} == TRUE ]]; then
  SAMPLE_DIR=$(mktemp -d)
  readonly SAMPLE_DIR
  chmod 777 "$SAMPLE_DIR"
  cp "$SCRIPT_DIR"/install_sample.sh "$SAMPLE_DIR"/install_sample.sh
  sudo su - oracle -c "$SAMPLE_DIR/install_sample.sh $ORACLE_PASSWORD localhost/$ORACLE_PDB"
  sudo su - oracle -c "rm -rf $SAMPLE_DIR/*"
  rmdir "$SAMPLE_DIR"
fi
