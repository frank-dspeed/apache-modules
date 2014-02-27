# runnable base
FROM ubuntu:precise

# REPOS
RUN apt-get -y update && locale-gen en_GB.UTF-8
RUN apt-get install -y -q python-software-properties
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) multiverse"
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates multiverse"

RUN apt-get -y update

# BASICS
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q vim nano curl git make wget build-essential g++ sendmail

## APACHE
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q\
  apache2-mpm-worker libapache2-mod-fastcgi libapache2-modsecurity

RUN echo apache2-mpm-worker hold | sudo dpkg --set-selections

## PHP
RUN add-apt-repository -y ppa:ondrej/php5; apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q\
  openssh-server supervisor\
  cron\
  php5-fpm php5 php5-cli php5-dev php-pear php5-common php5-apcu\
  php5-mcrypt php5-gd php5-mysql php5-curl php5-json\
  memcached php5-memcached\
  imagemagick graphicsmagick graphicsmagick-libmagick-dev-compat php5-imagick

RUN pecl install memcache; 
ADD ./config/php5/mods-available/memcache.ini /etc/php5/mods-available/memcache.ini
RUN /usr/sbin/php5enmod memcache

## CONFIG
# Apache + PHP-FPM
RUN a2enmod actions fastcgi alias headers deflate rewrite; a2dismod autoindex
RUN wget -q https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb; sudo dpkg -i mod-pagespeed-*.deb; apt-get -f install; rm mod-pagespeed-*.deb
ADD ./config/apache2/apache2.conf /etc/apache2/apache2.conf
ADD ./config/apache2/envvars /etc/apache2/envvars
ADD ./config/apache2/mods-enabled/mod-securty.conf /etc/apache2/mods-enabled/mod-securty.conf
ADD ./config/apache2/sites-available/default /etc/apache2/sites-available/default
ADD ./config/modsecurity/modsecurity.conf /etc/modsecurity/modsecurity.conf
ADD ./config/apache2/mods-enabled/pagespeed.conf /etc/apache2/mods-enabled/pagespeed.conf
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

ADD ./config/php5/fpm/php.ini /etc/php5/fpm/php.ini
ADD ./config/php5/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD ./config/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf

# Supervisord
RUN mkdir -p /var/log/supervisor


## USER
RUN useradd -d /var/www/app --no-create-home -g www-data user

# SSH
#ADD ./config/authorized_keys /root/.ssh/
#ADD ./config/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key
#ADD ./config/ssh/ssh_host_dsa_key.pub /etc/ssh/ssh_host_dsa_key.pub
#ADD ./config/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ecdsa_key
#ADD ./config/ssh/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ecdsa_key.pub
#ADD ./config/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
#ADD ./config/ssh/ssh_host_rsa_key.pub /etc/ssh/ssh_host_rsa_key.pub
#RUN chmod 600 /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/authorized_keys; mkdir -p /var/run/sshd
#RUN chmod 700 /root/.ssh && chown -R root /root/.ssh

#ADD config/supervisord.conf /etc/supervisord.conf

# PORTS
#EXPOSE 80 22
#ENV RUNNABLE_USER_DIR /var/www/app

## START
#ADD config/run.sh /
#RUN chmod +x /run.sh

#ENTRYPOINT ["/run.sh"]

