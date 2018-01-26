FROM ubuntu:16.04
MAINTAINER Dasitha <dazimax@gmail.com>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEN noninteractive

RUN dpkg-divert --local --rename --add /sbin/initctl && \
  ln -sf /bin/true /sbin/initctl && \
  mkdir /var/run/sshd && \
  mkdir /run/php && \
  apt-get update && \
  apt-get install -y --no-install-recommends apt-utils \
    software-properties-common \
    python-software-properties \
    language-pack-en-base && \

  LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
  apt-get update && apt-get upgrade -y && \
  apt-get install -y python-setuptools \
    curl \
    vim \
    git \
    nano \
    unzip \
		openssl \
    nginx \
		ssmtp \
    varnish \
		cron && \

    # Install PHP
    	apt-get install -y php7.1-fpm \
    		php7.1-mysql \
    	  php7.1-curl \
    	  php7.1-gd \
    	  php7.1-intl \
    	  php7.1-mcrypt \
    	  php7.1-sqlite \
    	  php7.1-tidy \
    	  php7.1-xmlrpc \
    	  php7.1-pgsql \
    	  php7.1-ldap \
    	  freetds-common \
    	  php7.1-sqlite3 \
    	  php7.1-json \
    	  php7.1-xml \
    	  php7.1-mbstring \
        php7.1-bcmath \
    	  php7.1-soap \
    	  php7.1-zip \
    	  php7.1-xsl \
        php7.1-cli \
    	  php7.1-xdebug
# Cleanup
RUN apt-get remove --purge -y software-properties-common \
        	python-software-properties && \
        	apt-get autoremove -y && \
        	apt-get clean && \
        	apt-get autoclean

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV PHP_MEMORY_LIMIT 2G
ENV PHP_PORT 9000
ENV PHP_PM dynamic
ENV PHP_PM_MAX_CHILDREN 10
ENV PHP_PM_START_SERVERS 4
ENV PHP_PM_MIN_SPARE_SERVERS 2
ENV PHP_PM_MAX_SPARE_SERVERS 6
ENV APP_MAGE_MODE default


#xdebug.ini conf

RUN echo "xdebug.remote_enable=true" >> /etc/php/7.1/mods-available/xdebug.ini \
    && echo "xdebug.remote_connect_back=on" >> /etc/php/7.1/mods-available/xdebug.ini \
    && echo "xdebug.remote_port=9002" >> /etc/php/7.1/mods-available/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /etc/php/7.1/mods-available/xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /etc/php/7.1/mods-available/xdebug.ini


RUN mkdir /etc/nginx/ssl

RUN openssl req -x509 -newkey rsa:2048 \
   -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
   -keyout "/etc/nginx/ssl/nginx.key" \
   -out "/etc/nginx/ssl/nginx.crt" \
   -nodes -days 365

COPY default.conf /etc/nginx/conf.d/
COPY default.conf_with_varnish /etc/nginx/conf.d/

RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.confori
RUN mv /etc/default/varnish /etc/default/varnishori
RUN mv /etc/varnish/default.vcl /etc/varnish/default.vclori
RUN mv /etc/php/7.1/fpm/php-fpm.conf /etc/php/7.1/fpm/php-fpm.confori

COPY php-fpm.conf /etc/php/7.1/fpm/

RUN sed -i '/![^#]/ s/\(^.*ulimit.*$\)/#\1/' /etc/init.d/varnish

COPY nginx.conf /etc/nginx/
COPY varnish /etc/default/
COPY default.vcl /etc/varnish/
COPY magento.conf /etc/nginx/
#java installation for elasticsearch
ENV JAVA_HOME       /usr/lib/jvm/java-8-oracle
#RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN apt-get update && \
  apt-get dist-upgrade -y

## Remove any existing JDKs
RUN apt-get --purge remove openjdk*

## Install Oracle's JDK
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update && \
  apt-get install -y --no-install-recommends oracle-java8-installer && \
  apt-get clean all

COPY elasticsearch-2.4.5.deb /tmp/
RUN dpkg -i /tmp/elasticsearch-2.4.5.deb

WORKDIR /var/www/html

ADD scripts/init-services.sh /opt/scripts/init-services.sh
ADD scripts/start.sh /opt/scripts/start.sh
RUN chmod -R +x /opt/scripts && ln -s /opt/scripts/init-services.sh /usr/local/bin/init-services && ln -s /opt/scripts/start.sh /usr/local/bin/start


CMD init-services &&  /etc/init.d/varnish start &&  /etc/init.d/nginx start && /usr/local/bin/start
