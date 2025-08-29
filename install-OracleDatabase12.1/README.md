install-OracleDatabase12.1
==========================

Simple installation scripts for Oracle Database 12c Release 1 (12.1.0.2) Enterprise Edition single instance database.

Requirements
------------

### Oracle Linux Server 7 ###

Internet access is required to install the software from GitHub and Oracle Linux Yum Server.

Please refer to [Database Quick Installation Guide for Linux x86-64](https://docs.oracle.com/database/121/LTDQI/toc.htm#BABCEHFD) for the required memory and storage space.

### Oracle Database software ###

Download Oracle Database 12c Release 1 (12.1.0.2) software from [My Oracle Support](https://support.oracle.com/). Then place the downloaded files in the $MEDIA folder. (You can set the environment variable $MEDIA to any value you like.)

* p21419221_121020_Linux-x86-64_2of10.zip
* p21419221_121020_Linux-x86-64_1of10.zip

Configuration
-------------

Copy the file `dotenv.sample` to a new file named `.env` and modify the contents as needed.

```shell
MEDIA=/mnt
ORACLE_BASE=/u01/app/oracle
ORACLE_CHARACTERSET=AL32UTF8
ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1
ORACLE_PASSWORD=oracle
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
SELECT * FROM hr.employees WHERE rownum <= 10;
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
