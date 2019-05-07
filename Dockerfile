# Creates an image with all dependencies for drupal 7 website
# - Apache 2.4 with mod_rewrite enabled
# - PHP 7.2 with GD, curl, mbstring, uploadprogress

FROM ubuntu:18.04

LABEL maintainer="surreymagpie@yahoo.co.uk"

#set timezone and locale
RUN ln -snf /usr/share/zoneinfo/Europe/London /etc/localtime && \
    apt-get update && apt-get install -yqq \
    	locales \
    	tzdata && \
	locale-gen en_GB.utf8 && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install generic utilities
RUN apt-get -yqq update && \
	apt-get -yqq install \
		git \
		gnupg \
		curl \
		sudo \
		supervisor \
		wget \
		zip \
		unzip && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Apache 2.4 and set the www-data user's UID:GID to 1000 so
# that they will have same permissions as first user on Unix systems
RUN apt-get update && \
	apt-get install -yqq apache2 && \
	usermod -u 1000 www-data && \
	groupmod -g 1000 www-data && \
	a2enmod rewrite

# Install PHP 7.2
RUN apt-get update && apt-get install -yqq \
		php7.2 \
		php7.2-curl \
		php7.2-fpm \
		php7.2-gd \
		php-geos \
		php7.2-mbstring \
		php7.2-mysql \
		php7.2-pdo \
		php-uploadprogress \
		php7.2-xml \
		php7.2-zip && \
	apt-get clean && apt-get autoremove && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	a2enmod proxy_fcgi setenvif && \
	a2enconf php7.2-fpm

RUN mkdir /run/php

RUN	apt-get -y update && \
	apt-get install -yqq mysql-client-5.7&& \
	apt-get clean && apt-get autoremove && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install NodeJS and npm
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
	apt-get -y update && \
	apt-get -yqq install nodejs

EXPOSE 80 443

ADD supervisord.conf /etc/supervisor/supervisord.conf

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

CMD ["supervisord"]
