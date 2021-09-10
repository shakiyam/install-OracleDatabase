install-OracleDatabase
======================

Installation scripts for Oracle Database.

Target Oracle Database and Installation scripts
-----------------------------------------------

* Oracle Database 12c Release 2 (12.2.0.1)
  + install-OracleDatabase12.2/provision.sh
* Oracle Database 12c Release 1 (12.1.0.2) Enterprise Edition
  + install-OracleDatabase12.1/provision.sh
* Oracle Database 11g Release 2 (11.2.0.4) Standard / Enterprise Edition
  + install-OracleDatabase11.2/provision.sh

Requirements
------------

Installation scripts support for Oracle Linux Server 7.

Download the Oracle Database installation binary from [My Oracle Support](https://support.oracle.com/) or [Oracle Software Delivery Cloud](https://edelivery.oracle.com/). Then place the downloaded file in the $MEDIA folder. (You can set the environment variable $MEDIA to any value you like.)

* Oracle Database 12c Release 2 (12.2.0.1)
  + V839960-01.zip
* Oracle Database 12c Release 1 (12.1.0.2) Enterprise Edition
  + p21419221_121020_Linux-x86-64_1of10.zip
  + p21419221_121020_Linux-x86-64_2of10.zip
* Oracle Database 11g Release 2 (11.2.0.4) Standard / Enterprise Edition
  + p13390677_112040_Linux-x86-64_1of7.zip
  + p13390677_112040_Linux-x86-64_2of7.zip

Internet access is required to install the software from GitHub and Oracle Linux Yum Server.

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
