install-OracleDatabase11.2
==========================

Simple installation scripts for Oracle Database 11g Release 2 (11.2.0.4) single instance database.

Requirements
------------

### Oracle Linux Server 7 ###

Internet access is required to install the software from GitHub and Oracle Linux Yum Server.

Please refer to [Database Quick Installation Guide for Linux x86-64](https://docs.oracle.com/cd/E11882_01/install.112/e24326/toc.htm#i1011296) for the required memory and storage space.

### Oracle Database software ###

Download Oracle Database 11g Release 2 (11.2.0.4) software from [My Oracle Support](https://support.oracle.com/). Then place the downloaded files in the $MEDIA folder. (You can set the environment variable $MEDIA to any value you like.)

* p13390677_112040_Linux-x86-64_1of7.zip
* p13390677_112040_Linux-x86-64_2of7.zip

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
ORACLE_EDITION=EE
ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
ORACLE_PASSWORD=CHANGE_THIS_TO_STRONG_PASSWORD
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

Example of Use
--------------

Connect to the database and browse to the sample table.

```console
sudo su - oracle
sqlplus system/oracle
SELECT * FROM scott.emp;
-- If you have sample schemas installed
SELECT * FROM hr.employees WHERE rownum <= 10;
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
