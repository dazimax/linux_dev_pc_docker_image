#!/bin/bash

# Show what we execute
set -e
 

# Set permission
usermod -u $USER_ID www-data &&  chown -R $USER_ID:www-data  /var/www/html && chmod -R 775 /var/www/html
#usermod -u $USER_ID magento && chown -R magento:www-data /var/www/html && chmod -R 775 /var/www/html

