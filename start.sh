#!/bin/bash

# Start cron service
service cron start

# Start PHP-FPM in the foreground
exec php-fpm
