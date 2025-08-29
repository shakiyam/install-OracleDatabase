#!/bin/bash
set -eo pipefail

# Test result counters
passed=0
failed=0
warnings=0

if [[ -e ".env" ]]; then
  # shellcheck source=/dev/null
  . ./.env
elif [[ -e "dotenv.sample" ]]; then
  # shellcheck source=/dev/null
  . ./dotenv.sample
fi

if [[ -z "${ORACLE_SID}" ]] || [[ -z "${ORACLE_PASSWORD}" ]]; then
  echo "❌ ERROR: ORACLE_SID or ORACLE_PASSWORD not set"
  echo "Make sure you're running this from an Oracle installation directory"
  echo "with .env or dotenv.sample file"
  exit 1
fi

echo "=== Oracle Database Status Test ==="

export ORACLE_SID="${ORACLE_SID}"
# shellcheck source=/dev/null
[[ -f ~/.bash_profile ]] && source ~/.bash_profile

echo ""
echo "1. Testing Oracle Installation..."
echo -n "Checking if Oracle Database is installed ... "
if command -v sqlplus &>/dev/null; then
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
if lsnrctl status &>/dev/null; then
  echo "✅ RUNNING"
  ((++passed))
else
  echo "❌ NOT RUNNING"
  ((++failed))
fi

echo ""
echo "3. Testing Database Status..."
echo -n "Checking database status ... "
status=$(echo "SELECT status FROM v\$instance;" | sqlplus -s "/ as sysdba" |& grep -E "OPEN|MOUNTED|STARTED" | tr -d '[:space:]')
if [[ "${status}" = "OPEN" ]]; then
  echo "✅ OPEN"
  ((++passed))
elif [[ -n "${status}" ]]; then
  echo "⚠️  ${status}"
  ((++warnings))
else
  echo "❌ NOT RUNNING"
  ((++failed))
fi

echo ""
echo "4. Testing Database Connection (system)..."
echo -n "Testing connection: system ... "
connection_test_sql="SELECT 'CONNECTION_OK' FROM dual;"
if result=$(echo "${connection_test_sql}" | sqlplus -s "system/${ORACLE_PASSWORD}" 2>&1) && echo "${result}" | grep -q "^CONNECTION_OK$"; then
  echo "✅ SUCCESS"
  ((++passed))
else
  echo "❌ FAILED"
  echo "Error: ${result}" | head -5
  ((++failed))
fi

echo ""
echo "5. Testing Database Connection (sysdba)..."
echo -n "Testing connection: / as sysdba ... "
if result=$(echo "${connection_test_sql}" | sqlplus -s "/ as sysdba" 2>&1) && echo "${result}" | grep -q "^CONNECTION_OK$"; then
  echo "✅ SUCCESS"
  ((++passed))
else
  echo "❌ FAILED"
  echo "Error: ${result}" | head -5
  ((++failed))
fi

echo ""
echo "6. Testing PDB (if exists)..."
is_cdb=$(echo "SELECT cdb FROM v\$database;" | sqlplus -s "/ as sysdba" 2>&1)
if echo "${is_cdb}" | grep -q "ORA-00904"; then
  is_cdb="NO"
else
  is_cdb=$(echo "${is_cdb}" | grep -E "YES|NO" | tr -d '[:space:]')
fi

if [[ "${is_cdb}" = "YES" ]]; then
  echo "Container Database (CDB) detected"

  pdb_name="${ORACLE_PDB:-PDB1}"
  pdb_name_upper=$(echo "${pdb_name}" | tr '[:lower:]' '[:upper:]')

  echo -n "Checking PDB ${pdb_name_upper} ... "
  pdb_status=$(echo "SELECT name, open_mode FROM v\$pdbs WHERE name = '${pdb_name_upper}';" | sqlplus -s "/ as sysdba" 2>&1)
  if echo "${pdb_status}" | grep -q "READ WRITE"; then
    echo "✅ OPEN"
    ((++passed))
  elif echo "${pdb_status}" | grep -q "${pdb_name_upper}"; then
    echo "⚠️  MOUNTED"
    ((++warnings))
  else
    echo "❌ NOT FOUND"
    ((++failed))
  fi

  echo -n "Testing connection: system@localhost/${pdb_name} ... "
  if result=$(echo "${connection_test_sql}" | sqlplus -s "system/${ORACLE_PASSWORD}@localhost/${pdb_name}" 2>&1) && echo "${result}" | grep -q "^CONNECTION_OK$"; then
    echo "✅ SUCCESS"
    ((++passed))
  else
    echo "❌ FAILED"
    echo "Error: ${result}" | head -5
    ((++failed))
  fi
else
  echo "Non-CDB database"
fi

echo ""
echo "7. Testing Sample Schema (if installed)..."
hr_schema_check_sql="SELECT table_name FROM dba_tables WHERE owner = 'HR' AND table_name = 'EMPLOYEES';"
sample_query_sql="SELECT employee_id, first_name, last_name FROM hr.employees WHERE rownum <= 3;"
if [[ "${is_cdb}" = "YES" ]]; then
  echo "Checking sample schemas in ${pdb_name_upper}..."
  if echo "${hr_schema_check_sql}" | sqlplus -s "system/${ORACLE_PASSWORD}@localhost/${pdb_name}" |& grep -q "EMPLOYEES"; then
    echo "✅ HR schema found in ${pdb_name_upper}"
    echo "Sample query from HR.EMPLOYEES:"
    echo "${sample_query_sql}" | sqlplus -s "system/${ORACLE_PASSWORD}@localhost/${pdb_name}"
    ((++passed))
  else
    echo "ℹ️  Sample schemas not installed in ${pdb_name_upper}"
  fi
else
  echo "Checking sample schemas in non-CDB..."
  if echo "${hr_schema_check_sql}" | sqlplus -s "system/${ORACLE_PASSWORD}" |& grep -q "EMPLOYEES"; then
    echo "✅ HR schema found"
    echo "Sample query from HR.EMPLOYEES:"
    echo "${sample_query_sql}" | sqlplus -s "system/${ORACLE_PASSWORD}"
    ((++passed))
  else
    echo "ℹ️  Sample schemas not installed"
  fi
fi

echo ""
echo "======================================="
echo "=== Test Summary ==="
echo "Passed: ${passed}"
echo "Failed: ${failed}"
echo "Warnings: ${warnings}"
echo ""
if [[ ${failed} -eq 0 ]]; then
  echo "✅ All critical tests passed"
  exit 0
else
  echo "❌ ${failed} test(s) failed"
  exit 1
fi
