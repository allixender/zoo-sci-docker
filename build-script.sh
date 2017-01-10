#!/bin/bash

export RUNTIME_PACKAGES="apache2 cgal curl gdal geos gfortran-multilib libblas-dev libcairo2 libcgal10 \
libfcgi0ldbl libgd-dev libgdal1h libgeos-3.4.2 libgeos-c1 libgeotiff2 libgfortran3 libjpeg62 libqrencode3 \
liblapack-dev libmozjs185-1.0 libpng3 libproj0 libquadmath0 libtiff5 libwxbase3.0-0 libwxgtk3.0-0 \
libxml2 libxslt1.1 openssl python-tk python2.7 wget wx-common zip"

apt-get update -y \
      && apt-get install -y --no-install-recommends $RUNTIME_PACKAGES

export BUILD_PACKAGES="subversion unzip flex bison libxml2-dev autotools-dev autoconf libmozjs185-dev python-dev \
build-essential libxslt1-dev software-properties-common libgdal-dev automake libtool libcairo2-dev \
libgd-gd2-perl libgd2-xpm-dev ibwxbase3.0-dev  libwxgtk3.0-dev wx3.0-headers wx3.0-i18n \
libproj-dev libnetcdf-dev libfreetype6-dev libfcgi-dev libqrencode-dev \
libtiff5-dev libgeotiff-dev libcgal-dev gfortran"

apt-get install -y --no-install-recommends $BUILD_PACKAGES

# for mapserver
export CMAKE_C_FLAGS=-fPIC
export CMAKE_CXX_FLAGS=-fPIC

# useful declarations
export BUILD_ROOT=/opt/build
export ZOO_BUILD_DIR=/opt/build/zoo-project
export CGI_DIR=/usr/lib/cgi-bin
export CGI_DATA_DIR=$CGI_DIR/data
export CGI_TMP_DIR=$CGI_DATA_DIR/tmp
export CGI_CACHE_DIR=$CGI_DATA_DIR/cache
export WWW_DIR=/var/www/html

# should build already there from base
# mkdir -p $BUILD_ROOT \
#   && mkdir -p $CGI_DIR \
#   && mkdir -p $CGI_DATA_DIR \
#   && mkdir -p $CGI_TMP_DIR \
#   && mkdir -p $CGI_CACHE_DIR \
#   && ln -s /usr/lib/x86_64-linux-gnu /usr/lib64


svn checkout http://svn.zoo-project.org/svn/trunk/zoo-project/ $ZOO_BUILD_DIR \
  && cd $ZOO_BUILD_DIR/zoo-kernel && autoconf \
  && ./configure --with-cgi-dir=$CGI_DIR \
  --prefix=/usr \
  --exec-prefix=/usr \
  --with-fastcgi=/usr \
  --with-gdal-config=/usr/bin/gdal-config \
  --with-geosconfig=/usr/bin/geos-config \
  --with-python \
  --with-mapserver=$BUILD_ROOT/mapserver-6.0.4 \
  --with-xml2config=/usr/bin/xml2-config \
  --with-pyvers=2.7 \
  --with-js=/usr \
  --with-cgal \
  && make && make install || exit 1

# install zcfg and services after zoo kernel build
cd $ZOO_BUILD_DIR/zoo-services/ogr/base-vect-ops \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR//zoo-services/ogr/ogr2ogr/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/ogr/base-vect-ops-py/ \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/cgal/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/gdal/contour/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/gdal/dem/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/gdal/grid/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/gdal/ndvi/ \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/gdal/profile/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/gdal/translate/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/gdal/warp/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/hello-py/ \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/hello-fortran/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/qrencode/ \
  && make \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

cd $ZOO_BUILD_DIR/zoo-services/wcps-proxy/ \
  && cp cgi-env/*.* $CGI_DIR/ || exit 1

# however, auto additonal packages won't get removed
# maybe auto remove is a bit too hard
# RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
# ENV AUTO_ADDED_PACKAGES $(apt-mark showauto)
# RUN apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES

apt-get remove --purge -y $BUILD_PACKAGES \
  && rm -rf /var/lib/apt/lists/*

# clean up from base
rm -rf $BUILD_ROOT/mapserver-6.0.4
rm -rf $ZOO_BUILD_DIR
# rm -rf $BUILD_ROOT/thirds
