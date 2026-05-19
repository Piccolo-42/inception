FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php-fpm \
	php-mysql \
	php-curl \
	php-gd \
	php-intl \
	php-mbstring \
	php-xml \
	php-zip \
	curl \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/entrypoint_wp.sh /usr/local/bin/entrypoint_wp.sh
RUN chmod +x /usr/local/bin/entrypoint_wp.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["entrypoint_wp.sh"]
