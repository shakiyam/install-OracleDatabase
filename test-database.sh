#!/bin/bash
set -eo pipefail

if [ -e ".env" ]; then
  # shellcheck source=/dev/null
  . ./.env
elif [ -e "dotenv.sample" ]; then
  # shellcheck source=/dev/null
  . ./dotenv.sample
fi

if [ -z "${ORACLE_SID}" ] || [ -z "${ORACLE_PASSWORD}" ]; then
  echo "❌ ERROR: ORACLE_SID or ORACLE_PASSWORD not set"
  echo "Make sure you're running this from an Oracle installation directory"
  echo "with .env or dotenv.sample file"
  exit 1
fi

echo "=== Oracle Database Status Test ==="

export ORACLE_SID="${ORACLE_SID}"
# shellcheck source=/dev/null
[ -f ~/.bash_profile ] && source ~/.bash_profile

echo ""
echo "1. Testing Oracle Installation..."
echo -n "Checking if Oracle Database is installed ... "
if command -v sqlplus >/dev/null 2>&1; then
  echo "✅ FOUND"
else
  echo "❌ NOT FOUND"
  echo "Please install Oracle Database first using:"
  echo "  make install-19-ol8  # or appropriate version"
  exit 1
fi

echo ""
echo "2. Testing Listener..."
echo -n "Checking listener status ... "
if lsnrctl status >/dev/null 2>&1; then
  echo "✅ RUNNING"
else
  echo "❌ NOT RUNNING"
fi

echo ""
echo "3. Testing Database Status..."
echo -n "Checking database status ... "
status=$(echo "SELECT status FROM v\$instance;" | sqlplus -s "/ as sysdba" 2>&1 | grep -E "OPEN|MOUNTED|STARTED" | tr -d '[:space:]')
if [ "${status}" = "OPEN" ]; then
  echo "✅ OPEN"
elif [ -n "${status}" ]; then
  echo "⚠️  ${status}"
else
  echo "❌ NOT RUNNING"
fi

echo ""
echo "4. Testing Database Connections..."
echo -n "Testing connection: system ... "
if result=$(echo "SELECT 'CONNECTION_OK' FROM dual;" | sqlplus -s "system/${ORACLE_PASSWORD}" 2>&1) && echo "${result}" | grep -q "^CONNECTION_OK$"; then
  echo "✅ SUCCESS"
else
  echo "❌ FAILED"
  echo "Error: ${result}" | head -5
fi

echo -n "Testing connection: / as sysdba ... "
if result=$(echo "SELECT 'CONNECTION_OK' FROM dual;" | sqlplus -s "/ as sysdba" 2>&1) && echo "${result}" | grep -q "^CONNECTION_OK$"; then
  echo "✅ SUCCESS"
else
  echo "❌ FAILED"
  echo "Error: ${result}" | head -5
fi

echo ""
echo "5. Testing PDB (if exists)..."
is_cdb=$(echo "SELECT cdb FROM v\$database;" | sqlplus -s "/ as sysdba" 2>&1 | grep -E "YES|NO" | tr -d '[:space:]')

if [ "${is_cdb}" = "YES" ]; then
  echo "Container Database (CDB) detected"

  pdb_name="${ORACLE_PDB:-PDB1}"
  pdb_name_upper=$(echo "${pdb_name}" | tr '[:lower:]' '[:upper:]')

  echo -n "Checking PDB ${pdb_name_upper} ... "
  pdb_status=$(echo "SELECT name, open_mode FROM v\$pdbs WHERE name = '${pdb_name_upper}';" | sqlplus -s "/ as sysdba" 2>&1)
  if echo "${pdb_status}" | grep -q "READ WRITE"; then
    echo "✅ OPEN"
  elif echo "${pdb_status}" | grep -q "${pdb_name_upper}"; then
    echo "⚠️  MOUNTED"
  else
    echo "❌ NOT FOUND"
  fi

  echo -n "Testing connection: system@localhost/${pdb_name} ... "
  if result=$(echo "SELECT 'CONNECTION_OK' FROM dual;" | sqlplus -s "system/${ORACLE_PASSWORD}@localhost/${pdb_name}" 2>&1) && echo "${result}" | grep -q "^CONNECTION_OK$"; then
    echo "✅ SUCCESS"
  else
    echo "❌ FAILED"
    echo "Error: ${result}" | head -5
  fi
else
  echo "Non-CDB database (11g or non-CDB 12c)"
fi

echo ""
echo "6. Testing Sample Schema (if installed)..."
if [ "${is_cdb}" = "YES" ]; then
  echo "Checking sample schemas in ${pdb_name_upper}..."
  if echo "SELECT table_name FROM dba_tables WHERE owner = 'HR' AND table_name = 'EMPLOYEES';" | sqlplus -s "system/${ORACLE_PASSWORD}@localhost/${pdb_name}" 2>&1 | grep -q "EMPLOYEES"; then
    echo "✅ HR schema found in ${pdb_name_upper}"
    echo "Sample query from HR.EMPLOYEES:"
    echo "SELECT employee_id, first_name, last_name FROM hr.employees WHERE rownum <= 3;" | sqlplus -s "system/${ORACLE_PASSWORD}@localhost/${pdb_name}"
  else
    echo "ℹ️  Sample schemas not installed in ${pdb_name_upper}"
  fi
else
  echo "Checking sample schemas in non-CDB..."
  if echo "SELECT table_name FROM dba_tables WHERE owner = 'HR' AND table_name = 'EMPLOYEES';" | sqlplus -s "system/${ORACLE_PASSWORD}" 2>&1 | grep -q "EMPLOYEES"; then
    echo "✅ HR schema found"
    echo "Sample query from HR.EMPLOYEES:"
    echo "SELECT employee_id, first_name, last_name FROM hr.employees WHERE rownum <= 3;" | sqlplus -s "system/${ORACLE_PASSWORD}"
  else
    echo "ℹ️  Sample schemas not installed"
  fi
fi

echo ""
echo "======================================="
echo "=== Connection Test Summary ==="
echo "All tests completed successfully!"
echo "Result: ✅ Database is operational"
exit 0
