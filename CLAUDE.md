# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains automated installation scripts for various Oracle Database versions (11g R2 through 21c) on Oracle Linux. Each version has its own directory with consistent structure and scripts that handle the entire installation process including database creation and optional sample schemas.

## Development and Testing Commands

### Running Installation Scripts

Each Oracle Database version directory contains a `provision.sh` script that handles the complete installation:

```bash
# Navigate to specific version directory
cd install-OracleDatabase19/

# Create .env file from sample (mandatory step)
cp dotenv.sample .env
# Edit .env to set proper values, especially MEDIA path

# Run installation
./provision.sh
```

### Testing Database Connection

After installation, verify the database:

```bash
# Connect to CDB as system user
sudo su - oracle
sqlplus system/oracle

# Connect to PDB
sqlplus system/oracle@localhost/pdb1

# Test sample schemas (if installed)
SELECT JSON_OBJECT(*) FROM hr.employees WHERE rownum <= 3;
```

### Running ShellCheck (Code Quality)

```bash
# Check shell scripts for issues
shellcheck provision.sh
shellcheck install_sample.sh  # Oracle 21c only
```

## Architecture and Key Components

### Directory Structure Pattern

Each Oracle version follows the same structure:
- `provision.sh` - Main installation orchestrator
- `dotenv.sample` - Environment configuration template
- `db_install.rsp.mustache` - Oracle installer response template
- `dbca.rsp.mustache` - Database creation assistant response template
- `README.md` - Version-specific documentation

### Environment Configuration System

The scripts use a `.env` file (created from `dotenv.sample`) with these key variables:
- `MEDIA` - Directory containing Oracle installation ZIP files
- `ORACLE_BASE` - Oracle base directory (typically `/u01/app/oracle`)
- `ORACLE_HOME` - Oracle home directory
- `ORACLE_SID` - Database SID
- `ORACLE_PDB` - Pluggable database name
- `ORACLE_PASSWORD` - System passwords
- `ORACLE_SAMPLESCHEMA` - Whether to install sample schemas

### Template Processing

The scripts use Mustache templates (`.mustache` files) processed by the Mo tool to generate Oracle response files. Variables from `.env` are substituted into templates at runtime.

### Installation Flow

1. **Pre-requisite Installation**: Oracle preinstallation RPM packages
2. **Directory Setup**: Create Oracle directories with proper ownership
3. **Environment Configuration**: Set oracle user environment variables
4. **Software Installation**: Unzip and install Oracle Database software
5. **Post-Installation**: Run root scripts for kernel parameters
6. **Listener Creation**: Configure Oracle Net listener
7. **Database Creation**: Create database using DBCA with response file
8. **Sample Schemas**: Optional installation (21c has separate script)

### ARM Architecture Support

The `install-Oracle-Database-19c-for-LINUX-ARM/` directory contains specialized scripts for ARM64 architecture, using different installation media (`LINUX.ARM64_1919000_db_home.zip`).

### Error Handling Approach

Scripts use:
- `set -eu -o pipefail` for strict error handling
- Conditional `set +e` around Oracle installer (which may return non-zero on warnings)
- File existence checks before proceeding
- Temporary directory cleanup

## Important Considerations

- Installation requires root/sudo access for system configuration
- Oracle installation media must be downloaded separately from Oracle's website
- Scripts are designed for Oracle Linux 7/8 environments
- Each version has specific preinstallation RPM requirements
- The oracle user password is set during installation