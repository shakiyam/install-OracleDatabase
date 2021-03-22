install-OracleDatabase
======================

Installation scripts for Oracle Database.

Target Oracle Database and Installation scripts
-----------------------------------------------

* Oracle Database 12c Release 2 (12.2.0.1) Enterprise Edition
  + install-OracleDatabase12.2.sh
* Oracle Database 12c Release 1 (12.1.0.2) Enterprise Edition
  + install-OracleDatabase12.1.sh
* Oracle Database 11g Release 2 (11.2.0.1) Enterprise Edition
  + install-OracleDatabase11.2.sh

Requirements
------------

Installation scripts support for Oracle Linux Server 6 and Oracle Linux Server 7.

You have to download the installation binaries of Oracle Database from the [Oracle Technology Network](http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html) and put them into the $MEDIA folder. (You can set environment variable $MEDIA to whatever you like.)

* Oracle Database 12c Release 2 (12.2.0.1) Enterprise Edition
  + linuxx64_12201_database.zip 
* Oracle Database 12c Release 1 (12.1.0.2) Enterprise Edition
  + linuxamd64_12102_database_1of2.zip
  + linuxamd64_12102_database_2of2.zip
* Oracle Database 11g Release 2 (11.2.0.1) Enterprise Edition
  + linux.x64_11gR2_database_1of2.zip
  + linux.x64_11gR2_database_2of2.zip

Internet access is required to install the software from GitHub and Oracle Linux Yum Server.

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
