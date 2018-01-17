# Este es el dockerfile para la central telefonica con Asterisk y FreePBX
# Si deseas puedes escribirme a :Carlos Loredo <carlos.loredo@netlife.tel>
# Se usaron varias imagenes para componer esta imagen de una central telefonica
# Gracias a los creadores.


FROM j1mr10rd4n/debian-baseimage-docker:8.2.1
MAINTAINER Michael Mayer <swd@michael-mayer.biz>


# Variables
ENV DEBIAN_FRONTEND noninteractive
ENV ASTERISKUSER asterisk

RUN mkdir -p /var/run/asterisk \ 
	&& mkdir -p /etc/asterisk \
	&& mkdir -p /var/lib/asterisk \
	&& mkdir -p /var/log/asterisk \
	&& mkdir -p /var/spool/asterisk \
	&& mkdir -p /usr/lib/asterisk \
	&& mkdir -p /var/www/

# Agregar usuario Asterisk
RUN useradd -m $ASTERISKUSER \
	&& chown $ASTERISKUSER. /var/run/asterisk \ 
	&& chown -R $ASTERISKUSER. /etc/asterisk \
	&& chown -R $ASTERISKUSER. /var/lib/asterisk \
	&& chown -R $ASTERISKUSER. /var/log/asterisk \
	&& chown -R $ASTERISKUSER. /var/spool/asterisk \
	&& chown -R $ASTERISKUSER. /usr/lib/asterisk \
	&& chown -R $ASTERISKUSER. /var/www/ 
	

# Descarga de sonidos de alta calidad
WORKDIR /var/lib/asterisk/sounds
RUN curl -f -o asterisk-core-sounds-en-wav-current.tar.gz -L http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-wav-current.tar.gz \
	&& tar -xzf asterisk-core-sounds-en-wav-current.tar.gz \
	&& rm -f asterisk-core-sounds-en-wav-current.tar.gz \
	&& curl -f -o asterisk-extra-sounds-en-wav-current.tar.gz -L http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz \
	&& tar -xzf asterisk-extra-sounds-en-wav-current.tar.gz \
	&& rm -f asterisk-extra-sounds-en-wav-current.tar.gz \
	&& curl -f -o asterisk-core-sounds-en-g722-current.tar.gz -L http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-g722-current.tar.gz \
	&& tar -xzf asterisk-core-sounds-en-g722-current.tar.gz \
	&& rm -f asterisk-core-sounds-en-g722-current.tar.gz \
	&& curl -f -o asterisk-extra-sounds-en-g722-current.tar.gz -L http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-g722-current.tar.gz \
	&& tar -xzf asterisk-extra-sounds-en-g722-current.tar.gz \
	&& rm -f asterisk-extra-sounds-en-g722-current.tar.gz
	
RUN apt-get update && apt-get install -y unzip 

# Sonidos en español
RUN mkdir /var/lib/asterisk/sounds/es
WORKDIR /var/lib/asterisk/sounds/es 
RUN curl -f -o core.zip -L https://www.asterisksounds.org/sites/asterisksounds.org/files/sounds/es-MX/download/asterisk-sounds-core-es-MX-1.11.11.zip \
	&& curl -f -o extra.zip -L https://www.asterisksounds.org/sites/asterisksounds.org/files/sounds/es-MX/download/asterisk-sounds-extra-es-MX-1.12.11.zip \
	&& unzip -u core.zip \
	&& unzip -u extra.zip 
RUN rm -f core.zip \
	&& rm -f extra.zip 
RUN chown -R $ASTERISKUSER.$ASTERISKUSER /var/lib/asterisk/sounds/es  \
	&& find /var/lib/asterisk/sounds/es -type d -exec chmod 0775 {} \;



RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Actualizar sistema base
RUN apt-get update && apt-get -y upgrade

# Correr este comando al inicio de Docker
CMD ["/sbin/my_init"]

# Seguir pasos de FreePBX wiki
# http://wiki.freepbx.org/display/FOP/Installing+FreePBX+13+on+Ubuntu+Server+14.04.2+LTS


# Instalar dependencias requeridas
RUN apt-get install -y \
		apache2 \
		autoconf \
		automake \
		bison \
		build-essential \
		curl \
		flex \
		git \
		libasound2-dev \
		libcurl4-openssl-dev \
		libical-dev \
		libmyodbc \
		libmysqlclient-dev \
		libncurses5-dev \
		libneon27-dev \
		libnewt-dev \
		libodbc1 \
		libogg-dev \
		libspandsp-dev \
		libsqlite3-dev \
		libsrtp0-dev \
		libssl-dev \
		libtool \
		libvorbis-dev \
		libxml2-dev \
		mpg123 \
		mysql-client \
		mysql-server \
		openssh-server \
		php-pear \
		php5 \
		php5-cli \
		php5-curl \
		php5-gd \
		php5-mysql \
		pkg-config \
		sox \
		subversion \
		sqlite3 \
		unixodbc-dev \
		uuid \
		uuid-dev 

# Remplazando archivos por defecto para reducir el uso de memoria.
COPY conf/my-small.cnf /etc/mysql/my.cnf
COPY conf/mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf

RUN chown -R $ASTERISKUSER. /var/www/* \
	&& rm -rf /var/www/html


# Instalar requerimientos de Legacy pear 
RUN pear install Console_Getopt

# Compilar e instalar pjproject
WORKDIR /usr/src
RUN curl -sf -o pjproject.tar.bz2 -L http://www.pjsip.org/release/2.4/pjproject-2.4.tar.bz2 \
	&& tar -xjvf pjproject.tar.bz2 \
	&& rm -f pjproject.tar.bz2 \
	&& cd pjproject-2.4 \
	&& CFLAGS='-DPJ_HAS_IPV6=1' ./configure --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr \
	&& make dep \
	&& make \ 
	&& make install \
	&& rm -r /usr/src/pjproject-2.4

# Compilar e Instalar jansson
WORKDIR /usr/src
RUN curl -sf -o jansson.tar.gz -L http://www.digip.org/jansson/releases/jansson-2.7.tar.gz \
	&& mkdir jansson \
	&& tar -xzf jansson.tar.gz -C jansson --strip-components=1 \
	&& rm jansson.tar.gz \
	&& cd jansson \
	&& autoreconf -i \
	&& ./configure \
	&& make \
	&& make install \
	&& rm -r /usr/src/jansson

# Compilar e instalar Asterisk
WORKDIR /usr/src
RUN curl -f -o asterisk.tar.gz -L http://downloads.asterisk.org/pub/telephony/certified-asterisk/asterisk-certified-13.13-current.tar.gz
RUN mkdir asterisk \
	&& tar -xzf /usr/src/asterisk.tar.gz -C /usr/src/asterisk --strip-components=1 \
	&& rm asterisk.tar.gz 

WORKDIR /usr/src/asterisk
RUN ./configure 
RUN contrib/scripts/get_mp3_source.sh 
RUN make menuselect.makeopts 

# RUN ./menuselect/menuselect --list-options  
RUN ./menuselect/menuselect --enable=chan_sip --enable=format_mp3 --disable=BUILD_NATIVE
RUN	cat menuselect.makeopts 
RUN make 
RUN make install \
	&& make config \
	&& ldconfig \
	&& update-rc.d -f asterisk remove 

RUN rm -r /usr/src/asterisk

WORKDIR /tmp


# Descarga de dependencias (Asi se evita compilar asterisk&co durante el docker build)
RUN apt-get install -y \
		sudo \
		net-tools \
		coreutils 

# Configurar apache
RUN sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php5/apache2/php.ini \
	&& sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/apache2/apache2.conf \
	&& sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
	&& sed -i 's/VirtualHost \*:80/VirtualHost \*:8082/' /etc/apache2/sites-available/000-default.conf \
	&& sed -i 's/Listen 80/Listen 8082/' /etc/apache2/ports.conf


# Configurar servicios
COPY start-apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

COPY start-mysqld.sh /etc/service/mysqld/run
RUN chmod +x /etc/service/mysqld/run

COPY start-asterisk.sh /etc/service/asterisk/run
RUN chmod +x /etc/service/asterisk/run

COPY start-amportal.sh /etc/my_init.d/start-amportal.sh
	

#Make CDRs work
COPY conf/cdr/odbc.ini /etc/odbc.ini
COPY conf/cdr/odbcinst.ini /etc/odbcinst.ini
COPY conf/cdr/cdr_adaptive_odbc.conf /etc/asterisk/cdr_adaptive_odbc.conf
RUN chown asterisk:asterisk /etc/asterisk/cdr_adaptive_odbc.conf \
	&& chmod 775 /etc/asterisk/cdr_adaptive_odbc.conf

# Descargar y preparar FreePBX
WORKDIR /usr/src

# Download and unzip 
RUN curl -f -o freepbx.tgz -L http://mirror.freepbx.org/modules/packages/freepbx/freepbx-13.0-latest.tgz 
RUN tar xfz freepbx.tgz
RUN rm -rf freepbx.tgz

# Prepare install
RUN a2enmod rewrite
COPY ./conf/asterisk.conf /etc/asterisk/

# install
COPY install-freepbx.sh /
RUN chmod +x /install-freepbx.sh
RUN /install-freepbx.sh
RUN rm -rf /usr/src/freepbx









##################
# Limpieza
##################
RUN apt-get remove -y --purge autoconf \
		automake \
		bison \
		build-essential \
		flex \
		git \
		libasound2-dev \
		libcurl4-openssl-dev \
		libical-dev \
		libmysqlclient-dev \
		libncurses5-dev \
		libneon27-dev \
		libnewt-dev \
		libogg-dev \
		libspandsp-dev \
		libsqlite3-dev \
		libsrtp0-dev \
		libssl-dev \
		libvorbis-dev \
		libxml2-dev \
		openssh-server \
		subversion \
		unixodbc-dev \
		uuid-dev 



RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

VOLUME ["/etc/asterisk","/etc/apache2","/var/www/html","/var/lib/mysql","/var/spool/asterisk","/var/lib/asterisk"]