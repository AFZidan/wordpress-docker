#!/bin/bash

# Set PATH and environment for cron
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Run WordPress cron with explicit path
/usr/local/bin/wp cron event run --due-now --allow-root --path=/var/www/html

# Log the execution
echo "$(date): WordPress cron executed" >> /var/log/php/wp-cron.log
