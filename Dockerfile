FROM php:8.2-fpm

# Install required PHP extensions and cron
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libonig-dev libxml2-dev zip unzip git curl cron \
    && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd

# Install WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Install Node.js (LTS) and latest npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Create PHP error log dir
RUN mkdir -p /var/log/php && touch /var/log/php/php_errors.log

# Copy PHP config
COPY php.ini /usr/local/etc/php/conf.d/uploads.ini

# Copy and set up cron
COPY wp-cron.sh /var/www/html/wp-cron.sh
COPY crontab /etc/cron.d/wordpress-cron
COPY start.sh /start.sh
RUN chmod 0644 /etc/cron.d/wordpress-cron && \
    chmod +x /var/www/html/wp-cron.sh && \
    chmod +x /start.sh && \
    crontab /etc/cron.d/wordpress-cron

# Set working directory
WORKDIR /var/www/html

# Override FPM config to listen on 0.0.0.0:9000 (not socket)
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

# Set the startup command
CMD ["/start.sh"]
