# runnable base
FROM ubuntu:precise

# REPOS
RUN apt-get -y update && locale-gen en_GB.UTF-8
RUN echo "Europe/London" | tee /etc/timezone; dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get install -y -q python-software-properties
# RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) multiverse"
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates multiverse"

RUN apt-get -y update

# BASICS
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q vim nano curl git subversion make wget build-essential g++ sendmail unzip logrotate

## APACHE
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q\
  apache2-mpm-worker libapache2-mod-fastcgi libapache2-modsecurity

RUN echo apache2-mpm-worker hold | dpkg --set-selections

## PHP
RUN add-apt-repository -y ppa:ondrej/php5; apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q\
  openssh-server supervisor\
  cron\
  php5-fpm php5 php5-cli php5-dev php-pear php5-common php5-apcu\
  php5-mcrypt php5-gd php5-mysql php5-curl php5-json\
  memcached php5-memcached\
  imagemagick graphicsmagick graphicsmagick-libmagick-dev-compat php5-imagick trimage

RUN pecl install memcache; 
ADD ./config/php5/mods-available/memcache.ini /etc/php5/mods-available/memcache.ini
RUN /usr/sbin/php5enmod memcache

## CONFIG
# USER
RUN useradd -d /var/www/app --no-create-home -g www-data -G adm user

# Apache + PHP-FPM
RUN a2enmod actions fastcgi alias headers deflate rewrite; a2dismod autoindex
RUN wget -q https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb; sudo dpkg -i mod-pagespeed-*.deb; apt-get -f install; rm mod-pagespeed-*.deb
ADD ./config/apache2/apache2.conf /etc/apache2/apache2.conf
ADD ./config/apache2/envvars /etc/apache2/envvars
ADD ./config/apache2/mods-enabled/mod-securty.conf /etc/apache2/mods-enabled/mod-securty.conf
ADD ./config/apache2/sites-available/default /etc/apache2/sites-available/default
ADD ./config/modsecurity/modsecurity.conf /etc/modsecurity/modsecurity.conf
ADD ./config/apache2/mods-enabled/pagespeed.conf /etc/apache2/mods-enabled/pagespeed.conf
RUN mkdir -p /var/log/app; chmod 664 /var/log/app/; chown user:www-data /var/log/app/; chown www-data: -R /var/lib/apache2/fastcgi

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

ADD ./config/php5/fpm/php.ini /etc/php5/fpm/php.ini
ADD ./config/php5/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD ./config/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf
ADD ./config/php5/mods-available/opcache.ini /etc/php5/mods-available/opcache.ini

# Supervisord
RUN mkdir -p /var/log/supervisor


# SSH
ADD ./config/ssh/sshd_config /etc/ssh/sshd_config


