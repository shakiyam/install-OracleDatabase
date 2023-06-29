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

Copy the file `dotenv.sample` to a new file named `.env` and modify the contents as needed.

```shell
MEDIA=/mnt
ORACLE_BASE=/u01/app/oracle
ORACLE_CHARACTERSET=AL32UTF8
ORACLE_HOME=/u01/app/oracle/product/19.19.0/dbhome_1
ORACLE_PASSWORD=oracle
ORACLE_PDB=pdb1
ORACLE_SAMPLESCHEMA=TRUE
ORACLE_SID=orcl
```

Provision
---------

When you run `provision.sh`, the following will be performed internally.

* Install Oracle Preinstallation RPM
* Create directories
* Set environment variables
* Set password for oracle user
* Unzip downloaded Oracle Database software
* Install Oracle Database
* Create a listener
* Create a database

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
