#!/bin/bash
set -eu -o pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: install_sample.sh password connect_string"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR

curl -L# https://github.com/oracle/db-sample-schemas/archive/refs/tags/v21.1.tar.gz \
  | tar xzf - -C "$SCRIPT_DIR"
cd "$SCRIPT_DIR"/db-sample-schemas-21.1
perl -p -i.bak -e 's#__SUB__CWD__#'"$(pwd)"'#g' ./*.sql ./*/*.sql ./*/*.dat
echo "@mksample $1 $1 $1 $1 $1 $1 $1 $1 users temp $SCRIPT_DIR/log/ $2" \
  | sqlplus system/"$1"@"$2"
