These are notes I kept when trying to update GDAL on a RHEL 6.8 server. The version of GDAL from the EPEL repository is horribly out of date and doesn't play well with many of the newer geospatial packages in R (notably `sf`). No guarantees that these work but they should at least get close. As of this writing (2017-03-02), the versions of proj4 and geos pgdg96 and epel are up to date enough...

Create a home for all this
==========================

We will install this in a separate folder to keep things relatively clean.

``` bash
sudo mkdir /opt/source
```

And then go to this new locaiton

``` bash
cd /opt/source
```

GDAL From Source
================

sudo wget <http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz> sudo tar -zvxf gdal-2.1.3.tar.gz cd gdal-2.1.3 sudo ./configure
--prefix=/opt/source/gdal-2.1.3
--with-jpeg=external
--with-jpeg12
--without-libtool
--without-python
--with-libkml
--with-static-proj4=/opt/source/proj-4.8.0/build
--with-libtiff
--with-geotiff
--with-geos
--with-netcdf
--with-static-proj4

sudo make sudo make install sudo ldconfig

Set Paths
=========

Did this for shell by adding to a /etc/profile.d/custom\_exports.sh file
========================================================================

export PATH="/opt/source/gdal-2.1.3/bin:$PATH"

The above doesn't register for R, so updated /usr/lib64/R/etc/Renviron.site with
================================================================================

Once geos install from source work
==================================

/opt/source/gdal-2.1.3/bin at the end of PATH=""

Added
=====

LD\_LIBRARY\_PATH="/opt/source/gdal-2.1.3/lib"
