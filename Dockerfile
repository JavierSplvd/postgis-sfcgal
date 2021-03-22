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
ENV PROJ http://download.osgeo.org/proj/proj-8.0.0.tar.gz
#from https://gforge.inria.fr/frs/?group_id=52
ENV CGAL https://gforge.inria.fr/frs/download.php/file/35139/CGAL-4.6.3.tar.xz
#from https://github.com/Oslandia/SFCGAL/releases
ENV SFCGAL https://github.com/Oslandia/SFCGAL/archive/v1.3.8.tar.gz

#TODO make PROCESSOR_COUNT dynamic
#built by docker.io, so reducing to 1. increase to match build server processor count as needed
ENV PROCESSOR_COUNT 4

##Installation

#postgis required packages, PG_MAJOR from parent container
#lib building packages
#for address_standardizer
RUN apt-get -y update && apt-get -y install \
    build-essential postgresql-server-dev-$PG_MAJOR libxml2-dev libjson-c-dev \
    cmake libboost-dev libgmp-dev libmpfr-dev libboost-thread-dev libboost-system-dev \
    libpcre3-dev

#install qt
RUN apt-get install -y --force-yes qt5-default libqt5webkit5-dev

WORKDIR /install-postgis

WORKDIR /install-postgis/geos
ADD $GEOS /install-postgis/geos.tar.bz2
RUN tar xf /install-postgis/geos.tar.bz2 -C /install-postgis/geos --strip-components=1
RUN ./configure && make -j $PROCESSOR_COUNT && make install
RUN ldconfig
WORKDIR /install-postgis
RUN test -x geos

WORKDIR /install-postgis/gdal
ADD $GDAL /install-postgis/gdal.tar.gz
RUN tar xf /install-postgis/gdal.tar.gz -C /install-postgis/gdal --strip-components=1
RUN ./configure --with-geos=/usr/local/bin/geos-config && make -j $PROCESSOR_COUNT && make install
RUN ldconfig
WORKDIR /install-postgis
RUN test -x gdal

WORKDIR /install-postgis/proj
ADD $PROJ /install-postgis/proj.tar.gz
RUN tar xf /install-postgis/proj.tar.gz -C /install-postgis/proj --strip-components=1
RUN ./configure && make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis
RUN test -f /usr/local/include/proj_api.h

WORKDIR /install-postgis/cgal
ADD $CGAL /install-postgis/cgal.tar.xz
RUN tar xf /install-postgis/cgal.tar.xz -C /install-postgis/cgal --strip-components=1
RUN cmake . && make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis
RUN test -d /usr/local/lib/CGAL

WORKDIR /install-postgis/sfcgal
ADD $SFCGAL /install-postgis/sfcgal.tar.gz
RUN tar xf /install-postgis/sfcgal.tar.gz -C /install-postgis/sfcgal --strip-components=1
RUN cmake . && make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis
RUN test -x $sfcgal_config

WORKDIR /install-postgis/postgis
ADD $POSTGIS /install-postgis/postgis.tar.gz
RUN tar xf /install-postgis/postgis.tar.gz -C /install-postgis/postgis --strip-components=1
RUN ./configure --with-geosconfig=/usr/local/bin/geos-config --with-gdalconfig=/usr/local/bin/gdal-config --with-sfcgal=/usr/local/bin/sfcgal-config --with-projdir=/usr/local --with-raster --with-topology && make
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