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

Copy the file `dotenv.sample` to a new file named `.env` and modify the contents as needed.

```shell
MEDIA=/mnt
ORACLE_BASE=/u01/app/oracle
ORACLE_CHARACTERSET=AL32UTF8
ORACLE_EDITION=EE
ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
ORACLE_PASSWORD=oracle
ORACLE_SAMPLESCHEMA=TRUE
ORACLE_SID=orcl
```

Provision
---------

When you run `provision.sh`, the following will be performed internally.

* Install Oracle Preinstallation RPM and unzip
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
