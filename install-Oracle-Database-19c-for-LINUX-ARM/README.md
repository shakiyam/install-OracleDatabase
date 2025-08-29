install-Oracle-Database-19c-for-LINUX-ARM
=========================================

Simple installation scripts for Oracle Database 19c for LINUX ARM (19.19) single instance database.

Requirements
------------

### Oracle Linux Server 8 ###

Internet access is required to install the software from GitHub and Oracle Linux Yum Server.

Please refer to [Database Installation Guide for Linux](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/oracle-database-installation-checklist.html) for the required memory and storage space.

### Oracle Database software ###

Download Oracle Database 19c for LINUX ARM software from [Oracle Database Software Downloads](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html). Then place the downloaded file in the $MEDIA folder. (You can set the environment variable $MEDIA to any value you like.)

* LINUX.ARM64_1919000_db_home.zip

Configuration
-------------

**⚠️ IMPORTANT**: Always create a `.env` file before running provision.sh. 
Running without `.env` will use weak default passwords from `dotenv.sample`, creating a serious security risk.

Create a secure `.env` file from the sample with proper permissions:

```shell
# Create .env with restricted permissions (owner read/write only)
cp dotenv.sample .env
chmod 600 .env

# Edit the file and set a strong password (DO NOT use default 'oracle')
vi .env
```

**Security Note**: The `.env` file contains sensitive information. Always:
- Set file permissions to `600` (owner read/write only)
- Use strong, unique passwords (avoid default 'oracle')
- Never commit `.env` to version control (already in .gitignore)

Example configuration:
```shell
MEDIA=/mnt
ORACLE_BASE=/u01/app/oracle
ORACLE_CHARACTERSET=AL32UTF8
ORACLE_HOME=/u01/app/oracle/product/19.19.0/dbhome_1
ORACLE_PASSWORD=CHANGE_THIS_TO_STRONG_PASSWORD
ORACLE_PDB=pdb1
ORACLE_SAMPLESCHEMA=TRUE
ORACLE_SID=orcl
```

Provision
---------

When you run `provision.sh`, the following will be performed internally.

* Loading environment configuration
* Checking Oracle installation media
* Installing Oracle Preinstallation RPM and unzip
* Creating Oracle directories
* Setting Oracle environment variables
* Installing rlwrap for SQL*Plus
* Setting oracle user password
* Extracting Oracle Database software
* Installing Mo template processor
* Installing Oracle Database
* Creating Oracle Net Listener
* Creating database

```console
./provision.sh
```

Examples of Use
---------------

Connect to CDB root and confirm the connection.

```console
sudo su - oracle
sqlplus system/oracle
SHOW CON_NAME
```

Connect to PDB and confirm the connection. If you have sample schemas installed, browse to the sample table.

```console
sqlplus system/oracle@localhost/pdb1
SHOW CON_NAME
-- If you have sample schemas installed
SELECT JSON_OBJECT(*) FROM hr.employees WHERE rownum <= 3;
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
