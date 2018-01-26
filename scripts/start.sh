#!/bin/bash
[ ! -z "${PHP_MEMORY_LIMIT}" ]         && sed -i "s/PHP_MEMORY_LIMIT/${PHP_MEMORY_LIMIT}/" /etc/php/7.1/fpm/php.ini
[ ! -z "${PHP_PORT}" ]                 && sed -i "s/PHP_PORT/${PHP_PORT}/" /etc/php/7.1/fpm/php-fpm.conf
[ ! -z "${PHP_PM_MAX_CHILDREN}" ]      && sed -i "s/PHP_PM_MAX_CHILDREN/${PHP_PM_MAX_CHILDREN}/" /etc/php/7.1/fpm/php-fpm.conf
[ ! -z "${PHP_PM_START_SERVERS}" ]     && sed -i "s/PHP_PM_START_SERVERS/${PHP_PM_START_SERVERS}/" /etc/php/7.1/fpm/php-fpm.conf
[ ! -z "${PHP_PM_MIN_SPARE_SERVERS}" ] && sed -i "s/PHP_PM_MIN_SPARE_SERVERS/${PHP_PM_MIN_SPARE_SERVERS}/" /etc/php/7.1/fpm/php-fpm.conf
[ ! -z "${PHP_PM_MAX_SPARE_SERVERS}" ] && sed -i "s/PHP_PM_MAX_SPARE_SERVERS/${PHP_PM_MAX_SPARE_SERVERS}/" /etc/php/7.1/fpm/php-fpm.conf
[ ! -z "${APP_MAGE_MODE}" ]            && sed -i "s/APP_MAGE_MODE/${APP_MAGE_MODE}/" /etc/php/7.1/fpm/php-fpm.conf

# Make sure this line comes last, otherwise find/replace will replace above vars
[ ! -z "${PHP_PM}" ]                   && sed -i "s/PHP_PM/${PHP_PM}/" /etc/php/7.1/fpm/php-fpm.conf

/usr/sbin/php-fpm7.1
