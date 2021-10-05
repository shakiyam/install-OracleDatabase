install-OracleDatabase12.2
==========================

Simple installation scripts for Oracle Database 12c Release 2 (12.2.0.1) single instance database.

Requirements
------------

### Oracle Linux Server 7 ###

Internet access is required to install the software from GitHub and Oracle Linux Yum Server.

Please refer to [Installation Guide for Linux x86-64](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/ladbi/oracle-database-installation-checklist.html) for the required memory and storage space.

### Oracle Database software ###

Download Oracle Database 12c Release 2 (12.2.0.1) software from [Oracle Software Delivery Cloud](https://edelivery.oracle.com/). Then place downloaded file in the $MEDIA folder. (You can set the environment variable $MEDIA to any value you like.)

* V839960-01.zip

Configuration
-------------

Copy the file `dotenv.sample` to a file named `.env` and rewrite the contents as needed.

```shell
MEDIA=/mnt
ORACLE_BASE=/u01/app/oracle
ORACLE_CHARACTERSET=AL32UTF8
ORACLE_EDITION=EE
ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/dbhome_1
ORACLE_PASSWORD=oracle
ORACLE_PDB=pdb1
ORACLE_SAMPLESCHEMA=TRUE
ORACLE_SID=orcl
```

Provision
---------

When you run `provision.sh`, the following will work internally.

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

Example of use
--------------

Connect to CDB root and confirm the connection.

```console
sudo su - oracle
sqlplus system/oracle
SHOW CON_NAME
```

Connect to PDB and confirm the connection. If you have sample schema installed, browse to the sample table.

```console
sqlplus system/oracle@localhost/pdb1
SHOW CON_NAME
-- If you have sample schema installed
SELECT * FROM hr.employees WHERE rownum <= 10;
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
