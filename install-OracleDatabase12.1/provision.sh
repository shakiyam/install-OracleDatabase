#!/bin/bash
set -eu -o pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

step_count=0
total_steps=12
start_time=$(date +%s)
step_start_time=0

progress() {
  step_count=$((step_count + 1))
  local message="$1"
  step_start_time=$(date +%s)
  local start_timestamp
  start_timestamp=$(date -d "@${step_start_time}" '+%Y-%m-%d %H:%M:%S')
  echo -e "${BLUE}[${step_count}/${total_steps}] ${start_timestamp}${NC} ${YELLOW}Starting:${NC} $message"
}

success() {
  local message="$1"
  local end_time
  end_time=$(date +%s)
  local step_elapsed=$((end_time - step_start_time))
  local total_elapsed=$((end_time - start_time))
  local end_timestamp
  end_timestamp=$(date -d "@${end_time}" '+%Y-%m-%d %H:%M:%S')
  echo -e "${GREEN}✓ ${end_timestamp}${NC} $message ${GREEN}(${step_elapsed}s, total: ${total_elapsed}s)${NC}"
  echo
}

error() {
  local message="$1"
  echo -e "${RED}✗ Error:${NC} $message"
  exit 1
}

script_dir="$(cd "$(dirname "$0")" && pwd)"
readonly script_dir

progress "Loading environment configuration"
set -a
if [ -e "$script_dir"/.env ]; then
  # shellcheck disable=SC1091
  . "$script_dir"/.env
else
  echo 'Environment file .env not found. Using dotenv.sample.'
  # shellcheck disable=SC1091
  . "$script_dir"/dotenv.sample
fi
set +a
success "Environment loaded"

progress "Checking Oracle installation media"
declare -r -a files=("$MEDIA/p21419221_121020_Linux-x86-64_1of10.zip" "$MEDIA/p21419221_121020_Linux-x86-64_2of10.zip")

for file in "${files[@]}"; do
  if [[ ! -f "$file" ]]; then
    error "File not found: $file"
  fi
done
success "Installation media found"

progress "Installing Oracle Preinstallation RPM and unzip"
sudo yum -y install oracle-rdbms-server-12cR1-preinstall unzip &>/dev/null
success "Oracle Preinstallation RPM and unzip installed"

progress "Creating Oracle directories"
sudo mkdir -p "$ORACLE_BASE"/..
sudo chown -R oracle:oinstall "$ORACLE_BASE"/..
sudo chmod -R 775 "$ORACLE_BASE"/..
success "Oracle directories created"

progress "Setting Oracle environment variables"
sudo tee -a /home/oracle/.bash_profile <<EOT >/dev/null
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORACLE_SID=$ORACLE_SID
export PATH=\$PATH:\$ORACLE_HOME/bin
EOT
success "Environment variables configured"

progress "Installing rlwrap for SQL*Plus"
# shellcheck disable=SC1091
os_version=$(. /etc/os-release && echo "$VERSION")
readonly os_version
case ${os_version%%.*} in
  7)
    sudo yum -y install oracle-epel-release-el7 &>/dev/null
    sudo yum -y --enablerepo=ol7_developer_EPEL install rlwrap &>/dev/null
    sudo tee -a /home/oracle/.bashrc <<EOT >/dev/null
alias sqlplus='rlwrap sqlplus'
EOT
    ;;
esac
success "rlwrap installed"

progress "Setting oracle user password"
echo oracle:"$ORACLE_PASSWORD" | sudo chpasswd
success "Oracle password set"

temp_dir=$(mktemp -d)
readonly temp_dir
chmod 755 "$temp_dir"

progress "Extracting Oracle Database software"
for file in "${files[@]}"; do
  echo "  Extracting $(basename "$file")..."
  total_files=$(unzip -l "$file" 2>/dev/null | tail -1 | awk '{print $2}')
  unzip -o "$file" -d "$temp_dir" \
    |& awk -v total="$total_files" '
        BEGIN { count = 0 }
        /inflating:|extracting:/ {
            count++
            percent = int(count * 100 / total)
            printf "\r\033[K    [%3d%%] Extracting: %d/%d files", percent, count, total
            fflush()
        }
        END {
            if (count > 0) {
                printf "\r\033[K    [100%%] Extracted: %d/%d files\n", count, count
            }
        }
    '
done
success "Oracle software extracted"

progress "Installing Mo template processor"
curl -fL# https://github.com/tests-always-included/mo/archive/refs/tags/3.0.5.tar.gz \
  | tar xzf - -O mo-3.0.5/mo | sudo install -m 755 /dev/stdin /usr/local/bin/mo
success "Mo installed"

progress "Installing Oracle Database"
mo "$script_dir"/db_install.rsp.mustache >"$temp_dir"/db_install.rsp
sudo su - oracle -c "$temp_dir/database/runInstaller -silent -showProgress \
  -ignorePrereq -waitforcompletion -responseFile $temp_dir/db_install.rsp"
sudo "$ORACLE_BASE"/../oraInventory/orainstRoot.sh &>/dev/null
sudo "$ORACLE_HOME"/root.sh &>/dev/null
success "Oracle Database installed"

progress "Creating Oracle Net Listener"
sudo su - oracle -c "netca -silent -responseFile $ORACLE_HOME/assistants/netca/netca.rsp"
success "Listener created"

progress "Creating database"
mo "$script_dir"/dbca.rsp.mustache >"$temp_dir"/dbca.rsp
sudo su - oracle -c "dbca -silent -createDatabase -responseFile $temp_dir/dbca.rsp"
success "Database created"

rm -rf "$temp_dir"

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Oracle Database 12c R1 installation completed!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
total_time=$(($(date +%s) - start_time))
echo -e "Total time: ${BLUE}$((total_time / 60))m $((total_time % 60))s${NC}"
echo
echo "Database details:"
echo "  SID: $ORACLE_SID"
echo "  PDB: $ORACLE_PDB"
echo "  System password: $ORACLE_PASSWORD"
echo
echo "Connect with: sqlplus system/$ORACLE_PASSWORD@localhost/$ORACLE_PDB"
