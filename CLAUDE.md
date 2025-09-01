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

### Running Code Quality Checks

```bash
# Run all linting (hadolint, shellcheck, shfmt)
make lint

# Run individual linting tools
make shellcheck  # Check shell scripts for issues
make shfmt       # Check shell script formatting
make hadolint    # Lint Dockerfiles
```

### Docker Test Environment

A Docker-based test environment is available for testing Oracle Database installations in isolated containers.

#### Setup

1. Configure Oracle media path:
```bash
# Set ORACLE_MEDIA_PATH environment variable (default: /mnt)
export ORACLE_MEDIA_PATH=/path/to/oracle-media
```

2. Build Docker images:
```bash
make build
```

#### Installation and Testing

##### Version-specific Installation
```bash
# Install Oracle Database versions in containers
make install-11.2-ol7   # Oracle Database 11g R2 on Oracle Linux 7
make install-12.1-ol7   # Oracle Database 12c R1 on Oracle Linux 7
make install-12.2-ol7   # Oracle Database 12c R2 on Oracle Linux 7
make install-18-ol7     # Oracle Database 18c on Oracle Linux 7
make install-19-ol7     # Oracle Database 19c on Oracle Linux 7
make install-19-arm-ol8 # Oracle Database 19c ARM on Oracle Linux 8
make install-21-ol7     # Oracle Database 21c on Oracle Linux 7
make install-21-ol8     # Oracle Database 21c on Oracle Linux 8
```

##### Version-specific Testing
```bash
# Test database status after installation
make test-11.2-ol7   # Test Oracle Database 11g R2 on Oracle Linux 7
make test-12.1-ol7   # Test Oracle Database 12c R1 on Oracle Linux 7
make test-12.2-ol7   # Test Oracle Database 12c R2 on Oracle Linux 7
make test-18-ol7     # Test Oracle Database 18c on Oracle Linux 7
make test-19-ol7     # Test Oracle Database 19c on Oracle Linux 7
make test-19-arm-ol8 # Test Oracle Database 19c ARM on Oracle Linux 8
make test-21-ol7     # Test Oracle Database 21c on Oracle Linux 7
make test-21-ol8     # Test Oracle Database 21c on Oracle Linux 8
```

##### Manual Testing
```bash
# Enter containers for manual testing
make shell-ol7  # Enter Oracle Linux 7 container
make shell-ol8  # Enter Oracle Linux 8 container

# Inside container:
cd /workspace/install-OracleDatabase19
cp dotenv.sample .env
# Edit .env to set MEDIA=/mnt
sudo ./provision.sh
```

#### Project Structure

```
install-OracleDatabase/
├── Makefile              # Build, test, and linting commands
├── compose.yml           # Docker Compose configuration
├── Dockerfile.ol7        # Oracle Linux 7 base image
├── Dockerfile.ol8        # Oracle Linux 8 base image
├── setup-swap.sh         # Host swap space setup script for Oracle requirements
├── test-database.sh      # Database status testing script (validates DB installation)
├── CLAUDE.md             # AI assistant instructions for Claude Code
├── README.md             # Main project documentation
├── LICENSE               # Project license
└── install-*/            # Oracle Database installation scripts for each version
```

#### Available Make Commands

**General**:
- `make help` - Show all available commands

**Host Environment Setup**:
- `make setup-swap` - Setup swap space for Oracle installation (default: 2048MB)

**Container Management**:
- `make build` - Build Docker images
- `make build-ol7` - Build Oracle Linux 7 image
- `make build-ol8` - Build Oracle Linux 8 image
- `make clean` - Clean up all containers, volumes, and networks
- `make shell-ol7` - Enter Oracle Linux 7 container shell
- `make shell-ol8` - Enter Oracle Linux 8 container shell

**Installation**:
- `make install-[version]-[os]` - Install specific Oracle Database version

**Testing**:
- `make test-[version]-[os]` - Test specific Oracle Database installation

**Code Quality**:
- `make lint` - Run all linting (hadolint, shellcheck, shfmt)
- `make hadolint` - Lint Dockerfiles
- `make shellcheck` - Lint shell scripts
- `make shfmt` - Lint shell script formatting

#### Testing Matrix

| Oracle Version | Base OS | Container Image |
|---------------|---------|-----------------|
| 11g R2 | Oracle Linux 7 | install-oracledatabase-oracle-linux-7 |
| 12c R1 | Oracle Linux 7 | install-oracledatabase-oracle-linux-7 |
| 12c R2 | Oracle Linux 7 | install-oracledatabase-oracle-linux-7 |
| 18c | Oracle Linux 7 | install-oracledatabase-oracle-linux-7 |
| 19c | Oracle Linux 7 | install-oracledatabase-oracle-linux-7 |
| 19c ARM | Oracle Linux 8 | install-oracledatabase-oracle-linux-8 |
| 21c | Oracle Linux 7/8 | Both images |

#### Prerequisites

- **ShellCheck**: Install from https://github.com/koalaman/shellcheck#installing
- **shfmt**: Install from https://github.com/mvdan/sh#shfmt
- **hadolint**: Install from https://github.com/hadolint/hadolint#install
- **Docker or Podman**: Container runtime (auto-detected)
- **Docker Compose**: Required for orchestrating containers (docker compose or docker-compose)
- **Oracle installation media**: Downloaded separately from Oracle's website

#### Notes

- Oracle installation media must be placed in the directory specified by `ORACLE_MEDIA_PATH` environment variable
- Linting tools (ShellCheck, shfmt, hadolint) must be installed on the host system
- Containers run with testuser and sudo privileges for testing
- The Mo tool (Mustache template processor) is installed during provision.sh execution

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
- `ORACLE_CHARACTERSET` - Database character set (typically AL32UTF8)
- `ORACLE_EDITION` - Oracle Database edition (EE, SE2, etc.)

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