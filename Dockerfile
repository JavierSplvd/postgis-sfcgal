FROM postgres:13.2

###Versions

#from http://postgis.net/source
ENV POSTGIS_MAJOR 3.1
ENV POSTGIS_VERSION 3.1.1
ENV POSTGIS http://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz

#from http://trac.osgeo.org/geos/
ENV GEOS http://download.osgeo.org/geos/geos-3.9.1.tar.bz2
#from http://trac.osgeo.org/gdal/wiki/DownloadSource
ENV GDAL http://download.osgeo.org/gdal/3.0.4/gdal-3.0.4.tar.gz
#from https://github.com/OSGeo/proj.4/wiki
ENV PROJ https://github.com/OSGeo/PROJ/releases/download/8.0.0/proj-8.0.0.tar.gz
#from https://gforge.inria.fr/frs/?group_id=52
ENV CGAL https://gforge.inria.fr/frs/download.php/file/35139/CGAL-4.6.3.tar.xz
#from https://github.com/Oslandia/SFCGAL/releases
ENV SFCGAL https://github.com/Oslandia/SFCGAL/archive/v1.3.8.tar.gz

#TODO make PROCESSOR_COUNT dynamic
#built by docker.io, so reducing to 1. increase to match build server processor count as needed
ENV PROCESSOR_COUNT 1

##Installation

#postgis required packages, PG_MAJOR from parent container
#lib building packages
#for address_standardizer
# RUN apt-get -y update && apt-get -y install \
#     build-essential postgresql-server-dev-$PG_MAJOR libxml2-dev libjson-c-dev \
#     cmake libboost-dev libgmp-dev libmpfr-dev libboost-thread-dev libboost-system-dev \
#     libpcre3-dev
# RUN apt-get install -y pkg-config libtool automake zlib1g-dev sqlite3 libsqlite3-dev libcurl4-gnutls-dev libtiff5-dev
# RUN apt-get install -y libcgal-dev

RUN apt-get update

RUN apt-get install -y autoconf build-essential cmake docbook-mathml docbook-xsl libboost-dev libboost-thread-dev libboost-filesystem-dev libboost-system-dev libboost-iostreams-dev libboost-program-options-dev libboost-timer-dev libcunit1-dev libgdal-dev libgeos++-dev libgeotiff-dev libgmp-dev libjson-c-dev liblas-dev libmpfr-dev libopenscenegraph-dev libpq-dev libproj-dev libxml2-dev postgresql-server-dev-9.4 xsltproc git build-essential wget
RUN apt-get install -y libcgal-dev postgresql-server-dev-13

RUN apt-get install -y protobuf-compiler

#install qt
RUN apt-get install -y --force-yes qt5-default libqt5webkit5-dev

WORKDIR /install-postgis

WORKDIR /install-postgis/sfcgal
ADD $SFCGAL /install-postgis/sfcgal.tar.gz
RUN tar xf /install-postgis/sfcgal.tar.gz -C /install-postgis/sfcgal --strip-components=1
RUN cmake . && make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis
RUN test -x $sfcgal_config

WORKDIR /install-postgis/postgis
ADD $POSTGIS /install-postgis/postgis.tar.gz
RUN tar xf /install-postgis/postgis.tar.gz -C /install-postgis/postgis --strip-components=1
RUN ./configure --with-raster --with-topology --without-protobuf && make
WORKDIR /install-postgis/postgis/extensions/postgis
RUN make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis/postgis/extensions/postgis_topology
RUN make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis/postgis
RUN make install
WORKDIR /install-postgis
RUN ldconfig

ADD postgis-template.sh /docker-entrypoint-initdb.d/postgis-template.sh

WORKDIR /
RUN rm -rf /install-postgis