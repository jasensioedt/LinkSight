FROM php:8.4.27-apache

RUN docker-php-ext-install pdo_mysql

COPY api/ /var/www/html/api/
COPY php-security.ini /usr/local/etc/php/conf.d/zz-linksight-security.ini

RUN mkdir -p /var/lib/linksight/throttle \
    && chown -R www-data:www-data /var/www/html /var/lib/linksight \
    && chmod 700 /var/lib/linksight/throttle

EXPOSE 80
