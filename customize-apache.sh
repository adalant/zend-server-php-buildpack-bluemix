#!/bin/bash

export LD_LIBRARY_PATH=/app/apache/lib:/app/zend/lib
export APACHE_ENVVARS=/app/apache/etc/apache2/envvars

GROUP=`id -g -n`

# Change Apache port to one used in the instance
sed -i -e "s/80/${PORT}/" /app/apache/etc/apache2/ports.conf
sed -i -e 's/:80/:*/' /app/apache/etc/apache2/sites-available/000-default.conf

# Change UID and GID in Apache configuration to the one used in instance
sed -i -e "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=${USER}/" /app/apache/etc/apache2/envvars
sed -i -e "s/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=${GROUP}/" /app/apache/etc/apache2/envvars

# Change document root if needed
if [[ -n $ZEND_DOCUMENT_ROOT ]]; then
    sed -i -e "s|/app/www/html|/app/www/html/$ZEND_DOCUMENT_ROOT|g" /app/apache/etc/apache2/sites-available/000-default.conf
fi

# Change ServerName
SERVER_NAME=`/app/bin/json-env-extract.php VCAP_APPLICATION application_uris 0`
sed -i -e "s/#?ServerName .+\$/ServerName $SERVER_NAME/g" /app/apache/etc/apache2/sites-available/000-default.conf

# Remove post_activate.php
rm -f /app/zend/etc/conf.d/post_activate.php
